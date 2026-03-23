#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
[[ -L "$SCRIPT_PATH" ]] && SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
PROJECT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
BACKUP_SERVER=""
BACKUP_PATH=""

# shellcheck source=/dev/null
[[ -f "$PROJECT_DIR/private/dot-config.sh" ]] && source "$PROJECT_DIR/private/dot-config.sh"

require_private_config() {
  [[ -z "$BACKUP_SERVER" ]] && {
    print_error "Private config not found. Init private/ submodule first."
    exit 1
  }
}

BACKUP_FILES=(
  ".config/mimeapps.list.backup"
  ".gtkrc-2.0.hm-bak"
  ".config/gtk-3.0/gtk.css.hm-bak"
  ".config/gtk-3.0/settings.ini.hm-bak"
  ".config/gtk-4.0/gtk.css.hm-bak"
  ".config/gtk-4.0/settings.ini.hm-bak"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

get_sudo_pass() {
  grep SUDO_PASSWORD "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || true
}

run_sudo() {
  local pass
  pass=$(get_sudo_pass)
  if [[ -n "$pass" ]]; then
    echo "$pass" | sudo -S "$@"
  else
    sudo "$@"
  fi
}

is_ninkear_reachable() {
  ssh -o ConnectTimeout=3 -o BatchMode=yes "${1:-$BACKUP_SERVER}" "exit" 2>/dev/null
}

commit_repo_if_needed() {
  local repo_path="$1" commit_message="$2" name="$3"
  if [[ -n "$(git -C "$repo_path" status --porcelain 2>/dev/null)" ]]; then
    print_info "Committing changes in $name..."
    git -C "$repo_path" add -A
    git -C "$repo_path" commit -m "$commit_message"
  else
    print_info "No changes in $name"
  fi
}

NINKEAR_AVAILABLE=false
ensure_ninkear_connected() {
  if ping -c 1 -W 2 100.64.0.1 >/dev/null 2>&1; then
    NINKEAR_AVAILABLE=true
    print_success "Ninkear reachable - binary cache will be used"
  else
    print_warn "Ninkear not reachable - building without binary cache"
  fi
}

_sub_args=()
build_substituter_args() {
  _sub_args=()
  if [[ "$NINKEAR_AVAILABLE" == "false" ]]; then
    _sub_args=(--option substituters "https://cache.nixos.org https://nix-community.cachix.org https://cache.numtide.com")
  fi
}

verify_hostname() {
  local h
  h=$(hostname)
  if [[ ! -d "$PROJECT_DIR/hosts/$h" ]]; then
    print_error "No configuration found for host '$h' (missing hosts/$h/)"
    exit 1
  fi
  if ! grep -q "^[[:space:]]*$h[[:space:]]*=" "$PROJECT_DIR/flake.nix" 2>/dev/null; then
    print_warn "Host '$h' not found in flake.nix nixosConfigurations"
  fi
}

handle_backups() {
  while IFS= read -r -d '' file; do
    trash-put "$file"
  done < <(find "$HOME" -maxdepth 5 \( -name "*.hm-bak" -o -name "*.backup.[0-9]*" \) \
    -type f -not -path "$HOME/.local/share/Trash/*" -print0 2>/dev/null)
  for f in "${BACKUP_FILES[@]}"; do
    [[ -f "$HOME/$f" ]] && trash-put "$HOME/$f"
  done
}

do_rebuild() {
  local action="$1"
  shift
  local hostname
  hostname=$(hostname)
  verify_hostname
  handle_backups
  ensure_ninkear_connected
  build_substituter_args
  print_info "nixos-rebuild $action → $hostname"
  run_sudo nixos-rebuild "$action" \
    --flake "${PROJECT_DIR}?submodules=1#${hostname}" \
    "${_sub_args[@]}" "$@"
}

cmd_rebuild() {
  local dry=false extra=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry | -n)
        dry=true
        shift
        ;;
      --cores)
        extra+=(--max-jobs "$2")
        shift 2
        ;;
      *)
        print_error "Unknown option: $1"
        exit 1
        ;;
    esac
  done
  if $dry; then
    do_rebuild dry-activate "${extra[@]}"
    print_success "Dry-activate complete (no changes applied)"
  else
    do_rebuild switch "${extra[@]}"
    print_success "Rebuild complete"
  fi
}

cmd_rebuild_boot() {
  do_rebuild boot
  print_success "Rebuild complete — activate on next boot"
}

cmd_update() {
  print_info "Updating flake inputs..."
  local nixpkgs_rev
  nixpkgs_rev=$(curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]')
  if [[ -n "$nixpkgs_rev" ]]; then
    nix flake update
    nix flake lock --override-input nixpkgs "github:nixos/nixpkgs/$nixpkgs_rev"
    print_success "nixpkgs pinned to cached channel commit"
  else
    print_warn "Could not fetch cached nixpkgs revision - updating to HEAD"
    nix flake update
  fi
  do_rebuild switch
  print_success "Update and rebuild complete"
}

cmd_cleanup() {
  print_info "Cleaning up backup files..."
  handle_backups
  print_info "Collecting garbage (older than 7 days)..."
  run_sudo nix-collect-garbage --delete-older-than 7d
  print_success "Cleanup complete"
}

cmd_trim() {
  read -rp "Run fstrim on /? (y/N) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_sudo fstrim -v /
    print_success "fstrim complete"
  fi
}

cmd_backup() {
  require_private_config
  if ! is_ninkear_reachable; then
    print_error "Cannot connect to $BACKUP_SERVER - check Tailscale"
    exit 1
  fi
  print_info "Backing up dotfiles to $BACKUP_SERVER:$BACKUP_PATH..."
  ssh "$BACKUP_SERVER" "mkdir -p $BACKUP_PATH"
  rsync -avz --delete --chmod=Du+w,Fu+w "$PROJECT_DIR/" "$BACKUP_SERVER:$BACKUP_PATH/"
  print_success "Backup complete → $BACKUP_SERVER:$BACKUP_PATH"
}

cmd_cache() {
  local subcmd="${1:-}"
  case "$subcmd" in
    build)
      local cores=$(($(nproc) - 1))
      [[ $cores -lt 1 ]] && cores=1
      local failed=()
      for host in laptop-82sn ninkear; do
        print_info "Building $host..."
        if nix build "${PROJECT_DIR}?submodules=1#nixosConfigurations.$host.config.system.build.toplevel" \
          --no-link --max-jobs 1 --cores "$cores"; then
          print_success "$host built"
        else
          print_error "$host failed"
          failed+=("$host")
        fi
      done
      [[ ${#failed[@]} -gt 0 ]] && {
        print_error "Failed: ${failed[*]}"
        exit 1
      }
      print_success "All configurations built"
      ;;
    start)
      require_private_config
      local server_dotfiles="/home/romanv/Documents/dotfiles"
      [[ "$(hostname)" == "ninkear" ]] && {
        print_error "Run 'dot cache build' directly on ninkear"
        exit 1
      }
      is_ninkear_reachable || {
        print_error "Cannot connect to ninkear"
        exit 1
      }
      ssh -T "$BACKUP_SERVER" "cd $server_dotfiles && git pull"
      ssh -T "$BACKUP_SERVER" "tmux kill-session -t cache-build 2>/dev/null || true; \
        tmux new-session -d -s cache-build \
        'cd $server_dotfiles && dot cache build 2>&1 | tee /tmp/cache-build.log'"
      print_success "Cache build started on ninkear"
      echo "Check progress: dot cache status"
      ;;
    status)
      require_private_config
      is_ninkear_reachable || {
        print_error "Cannot connect to ninkear"
        exit 1
      }
      if ssh "$BACKUP_SERVER" "tmux has-session -t cache-build 2>/dev/null"; then
        print_info "Build is running..."
        ssh "$BACKUP_SERVER" "tail -20 /tmp/cache-build.log 2>/dev/null || echo 'No log yet'"
        echo "Live: ssh ninkear -t 'tmux attach'"
      elif ssh "$BACKUP_SERVER" "test -f /tmp/cache-build.log"; then
        print_success "Build completed"
        ssh "$BACKUP_SERVER" "tail -30 /tmp/cache-build.log"
      else
        print_info "No build in progress. Start with: dot cache start"
      fi
      ;;
    *)
      echo "Usage: dot cache [build|start|status]"
      exit 1
      ;;
  esac
}

cmd_server() {
  local subcmd="${1:-}"
  local server_host="${BACKUP_SERVER:-ninkear}"
  local server_dotfiles="/home/romanv/Documents/dotfiles"
  local server_backup="${BACKUP_PATH:-/home/romanv/backup/dotfiles}"

  case "$subcmd" in
    rebuild)
      is_ninkear_reachable "$server_host" || {
        print_error "Cannot connect to ninkear"
        exit 1
      }
      print_info "Pulling and rebuilding on ninkear..."
      ssh -t "$server_host" "cd \"$server_dotfiles\" && git pull --ff-only && dot rebuild"
      print_success "Server rebuild complete"
      ;;
    update)
      is_ninkear_reachable "$server_host" || {
        print_error "Cannot connect to ninkear"
        exit 1
      }

      print_info "Pulling local changes..."
      git -C "$PROJECT_DIR" pull --ff-only

      local private_repo="$PROJECT_DIR/private"
      if [[ -d "$private_repo" ]] && git -C "$private_repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch="$(git -C "$private_repo" branch --show-current 2>/dev/null || true)"
        if [[ -n "$branch" ]]; then
          git -C "$private_repo" pull --ff-only origin "$branch"
        else
          git -C "$PROJECT_DIR" submodule update --init --recursive --remote private
        fi
        commit_repo_if_needed "$private_repo" "chore(private): checkpoint before server update" "private"
      fi
      commit_repo_if_needed "$PROJECT_DIR" "chore(sync): checkpoint before server update" "dotfiles"

      print_info "Syncing to ninkear:$server_backup..."
      ssh "$server_host" "mkdir -p \"$server_backup\""
      ssh "$server_host" "set -e; \
        non_owned=\$(find \"$server_backup\" -mindepth 1 ! -user romanv -print -quit); \
        if [ -n \"\$non_owned\" ]; then \
          owner_group=\$(id -gn romanv 2>/dev/null || echo romanv); \
          sudo chown -R romanv:\$owner_group \"$server_backup\"; \
        fi"
      rsync -avz --delete --chmod=Du+w,Fu+w "$PROJECT_DIR/" "$server_host:$server_backup/"

      print_info "Updating flake and rebuilding on ninkear..."
      ssh -t "$server_host" "cd \"$server_backup\" && \
        NIXPKGS_REV=\$(curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]') && \
        nix flake update && \
        nix flake lock --override-input nixpkgs \"github:nixos/nixpkgs/\$NIXPKGS_REV\" && \
        dot rebuild && \
        if ! git diff --quiet flake.lock 2>/dev/null; then \
          git add flake.lock && git commit -m 'chore: update flake inputs' && git push origin main; \
        fi"
      print_success "Server update complete"
      ;;
    *)
      echo "Usage: dot server [rebuild|update]"
      exit 1
      ;;
  esac
}

cmd_doctor() {
  echo -e "${BOLD}System Health Checks${NC}\n"

  local passed=0 warned=0 failed=0
  pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((passed++))
  }
  fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((failed++))
  }
  warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((warned++))
  }
  info() { echo -e "${BLUE}[INFO]${NC} $1"; }

  echo -e "${BLUE}=== System ===${NC}"
  # shellcheck disable=SC1091
  [[ -f /etc/os-release ]] && {
    . /etc/os-release
    info "NixOS $VERSION"
  }
  info "Kernel: $(uname -r)"
  local h
  h=$(hostname)
  [[ -d "$PROJECT_DIR/hosts/$h" ]] && pass "Host config exists ($h)" || fail "Missing host config ($h)"

  echo -e "\n${BLUE}=== Services ===${NC}"
  local sys_failed usr_failed
  sys_failed=$(systemctl --system --failed --no-legend 2>/dev/null | wc -l)
  usr_failed=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)
  if [[ "$sys_failed" -eq 0 ]]; then
    pass "No failed system services"
  else
    fail "$sys_failed failed system service(s)"
    systemctl --system --failed --no-legend 2>/dev/null
  fi
  if [[ "$usr_failed" -eq 0 ]]; then
    pass "No failed user services"
  else
    fail "$usr_failed failed user service(s)"
    systemctl --user --failed --no-legend 2>/dev/null
  fi

  echo -e "\n${BLUE}=== Disk ===${NC}"
  local usage
  usage=$(df / --output=pcent | tail -1 | tr -d ' %')
  if [[ "$usage" -lt 80 ]]; then
    pass "Root: $usage%"
  elif [[ "$usage" -lt 90 ]]; then
    warn "Root: $usage% (consider cleanup)"
  else fail "Root: $usage% (critically low!)"; fi
  info "Nix store: $(du -sh /nix/store 2>/dev/null | cut -f1)"
  local gens
  gens=$(nix profile history --profile /nix/var/nix/profiles/system 2>/dev/null | grep -c "Version" || echo 0)
  [[ "$gens" -gt 10 ]] && warn "$gens generations (run: dot cleanup)" || pass "$gens generations"

  echo -e "\n${BLUE}=== Network ===${NC}"
  curl -s --max-time 5 https://nixos.org >/dev/null 2>&1 && pass "Internet OK" || warn "Cannot reach nixos.org"

  echo -e "\n${BLUE}=== Git ===${NC}"
  cd "$PROJECT_DIR" || exit 1
  git diff --quiet 2>/dev/null && pass "No uncommitted changes" || warn "Uncommitted changes in dotfiles"
  git fetch origin --quiet 2>/dev/null || true
  local ahead behind
  ahead=$(git rev-list origin/main..HEAD --count 2>/dev/null || echo 0)
  behind=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo 0)
  [[ "$ahead" -gt 0 ]] && info "$ahead commit(s) ahead of remote"
  [[ "$behind" -gt 0 ]] && warn "$behind commit(s) behind remote"
  [[ "$ahead" -eq 0 && "$behind" -eq 0 ]] && pass "Up to date with remote"

  echo ""
  echo -e "Results: ${GREEN}$passed passed${NC}, ${YELLOW}$warned warnings${NC}, ${RED}$failed failed${NC}"
  [[ "$failed" -gt 0 ]] && exit 1 || true
}

print_help() {
  echo -e "${BOLD}dot${NC} — NixOS Dotfiles CLI\n"
  echo -e "${BOLD}USAGE${NC}  dot [command] [options]\n"
  echo -e "${BOLD}SYSTEM${NC}"
  echo -e "  ${CYAN}rebuild${NC} [--dry] [--cores N]   Rebuild system"
  echo -e "  ${CYAN}rebuild-boot${NC}                   Rebuild for next boot"
  echo -e "  ${CYAN}update${NC}                         Update flake inputs and rebuild"
  echo -e "  ${CYAN}cleanup${NC}                        Trash backup files, GC old generations"
  echo -e "  ${CYAN}trim${NC}                           Run fstrim\n"
  echo -e "${BOLD}SERVER${NC}"
  echo -e "  ${CYAN}server rebuild${NC}                 Pull and rebuild on ninkear"
  echo -e "  ${CYAN}server update${NC}                  Sync, update flake, rebuild ninkear\n"
  echo -e "${BOLD}CACHE${NC}"
  echo -e "  ${CYAN}cache build${NC}                    Build all configs locally"
  echo -e "  ${CYAN}cache start${NC}                    Start remote build on ninkear"
  echo -e "  ${CYAN}cache status${NC}                   Check remote build progress\n"
  echo -e "${BOLD}OTHER${NC}"
  echo -e "  ${CYAN}backup${NC}                         Backup dotfiles to ninkear"
  echo -e "  ${CYAN}doctor${NC}                         Health checks"
}

main() {
  [[ $# -eq 0 ]] && {
    print_help
    exit 0
  }
  case "$1" in
    rebuild)
      shift
      cmd_rebuild "$@"
      ;;
    rebuild-boot)
      shift
      cmd_rebuild_boot "$@"
      ;;
    update)
      shift
      cmd_update "$@"
      ;;
    cleanup) cmd_cleanup ;;
    backup) cmd_backup ;;
    cache)
      shift
      cmd_cache "${1:-}"
      ;;
    server)
      shift
      cmd_server "${1:-}"
      ;;
    doctor) cmd_doctor ;;
    trim) cmd_trim ;;
    help | --help | -h) print_help ;;
    *)
      print_error "Unknown command: $1"
      echo
      print_help
      exit 1
      ;;
  esac
}

main "$@"
