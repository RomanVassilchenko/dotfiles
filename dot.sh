#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# dot - NixOS Dotfiles Management CLI
# =============================================================================
#
# A unified CLI for managing NixOS dotfiles, system rebuilds, and maintenance.
#
# Usage: dot [command] [options]
#
# Commands:
#   rebuild [opts]     - Rebuild NixOS system
#   rebuild-boot       - Rebuild for next boot
#   update [opts]      - Update flake and rebuild
#   cache [subcmd]     - Cache management (build, start, status, upgrade)
#   server [subcmd]    - Server management (rebuild, update)
#   cleanup [--gc]     - Clean old generations
#   backup             - Backup dotfiles to ninkear
#   doctor             - Run system health checks
#   trim               - Run fstrim for SSD
#   help               - Show this help
#
# =============================================================================

VERSION="2.0.0"
# Resolve symlink to get the actual dotfiles directory
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [[ -L "$SCRIPT_PATH" ]]; then
  SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
FLAKE_NIX_PATH="$PROJECT_DIR/flake.nix"
BACKUP_SERVER=""
BACKUP_PATH=""
HEADSCALE_HOST=""

if [[ -f "$PROJECT_DIR/private/dot-config.sh" ]]; then
  # shellcheck source=/dev/null
  source "$PROJECT_DIR/private/dot-config.sh"
fi

require_private_config() {
  if [[ -z "$BACKUP_SERVER" ]]; then
    print_error "Private config not found. Init private/ submodule first."
    exit 1
  fi
}

# Backup files to clean before rebuild
BACKUP_FILES=(
  ".config/mimeapps.list.backup"
  ".gtkrc-2.0.hm-bak"
  ".config/gtk-3.0/gtk.css.hm-bak"
  ".config/gtk-3.0/settings.ini.hm-bak"
  ".config/gtk-4.0/gtk.css.hm-bak"
  ".config/gtk-4.0/settings.ini.hm-bak"
)

# =============================================================================
# Colors
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
  echo -e "${BOLD}${CYAN}$1${NC}"
}

print_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

check_command() {
  command -v "$1" &>/dev/null
}

# Pre-authenticate sudo (uses .env password if available, otherwise prompts)
setup_sudo() {
  local env_file="$PROJECT_DIR/.env"
  if [[ -f "$env_file" ]]; then
    local sudo_pass
    sudo_pass=$(grep SUDO_PASSWORD "$env_file" | cut -d'=' -f2 | tr -d '"')
    if [[ -n "$sudo_pass" ]]; then
      echo "$sudo_pass" | sudo -S -v 2>/dev/null && return 0
    fi
  fi
  sudo -v
}

# Check if ninkear is reachable via SSH
is_ninkear_reachable() {
  local server="${1:-$BACKUP_SERVER}"
  ssh -o ConnectTimeout=3 -o BatchMode=yes "$server" "exit" 2>/dev/null
}

repo_has_changes() {
  local repo_path="$1"
  [[ -n "$(git -C "$repo_path" status --porcelain 2>/dev/null)" ]]
}

commit_repo_if_needed() {
  local repo_path="$1"
  local commit_message="$2"
  local repo_name="$3"

  if repo_has_changes "$repo_path"; then
    print_info "Committing changes in $repo_name..."
    git -C "$repo_path" add -A
    git -C "$repo_path" commit -m "$commit_message"
    print_success "Committed changes in $repo_name"
  else
    print_info "No changes to commit in $repo_name"
  fi
}

# Ensure Tailscale connection to ninkear for binary cache
NINKEAR_AVAILABLE=false

ensure_ninkear_connected() {
  print_info "Checking ninkear P2P connection for binary cache..."

  if tailscale status --json 2>/dev/null | jq -e '.BackendState == "Running"' >/dev/null 2>&1; then
    print_success "Ninkear P2P already connected"
    NINKEAR_AVAILABLE=true
    return
  fi

  print_info "Tailscale not connected. Connecting to ninkear P2P..."

  # Start cloudflared tunnel only if not already running
  if ! ss -tlnp 2>/dev/null | grep -q ':18085'; then
    cloudflared access tcp \
      --hostname "$HEADSCALE_HOST" \
      --url 127.0.0.1:18085 &
    CLOUDFLARED_PID=$!
    sleep 2
  fi

  local tailscale_bin
  tailscale_bin=$(command -v tailscale 2>/dev/null) || true
  if [[ -z "$tailscale_bin" ]]; then
    print_warn "tailscale binary not found - skipping P2P connect"
    [[ -n "${CLOUDFLARED_PID:-}" ]] && kill $CLOUDFLARED_PID 2>/dev/null || true
    return
  fi
  if sudo "$tailscale_bin" up --login-server http://127.0.0.1:18085 --accept-routes --accept-dns=false; then
    print_success "Connected to ninkear P2P"
    NINKEAR_AVAILABLE=true
  else
    print_warn "Failed to connect to ninkear P2P - build may be slower without binary cache"
    [[ -n "${CLOUDFLARED_PID:-}" ]] && kill $CLOUDFLARED_PID 2>/dev/null || true
  fi
}

# Returns substituter override args if ninkear is unavailable
nix_substituter_args() {
  if [[ "$NINKEAR_AVAILABLE" == "false" ]]; then
    echo "--option substituters https://cache.nixos.org https://nix-community.cachix.org https://cache.numtide.com"
  fi
}

# Verify host configuration exists
verify_hostname() {
  local current_hostname
  current_hostname="$(hostname)"

  local folder="$PROJECT_DIR/hosts/$current_hostname"
  if [[ ! -d "$folder" ]]; then
    print_error "No configuration found for host '$current_hostname'"
    echo "  Missing folder: $folder" >&2
    echo "" >&2
    echo "Hint: Run 'dot add-host $current_hostname' to create configuration" >&2
    echo "      or run 'dot setup' for guided setup" >&2
    exit 1
  fi

  if [[ -f "$FLAKE_NIX_PATH" ]]; then
    if ! grep -q "^[[:space:]]*$current_hostname[[:space:]]*=" "$FLAKE_NIX_PATH"; then
      print_warn "Configuration for '$current_hostname' not found in flake.nix outputs"
      echo "  Host folder exists, but nixosConfiguration may be missing" >&2
    fi
  fi
}

# Clean up backup files before rebuild
handle_backups() {
  print_info "Checking for backup files to move to trash..."

  # Clean up .hm-bak files
  find "$HOME" -maxdepth 3 -name "*.hm-bak" -type f 2>/dev/null | while read -r file; do
    echo "Moving to trash: $file"
    trash-put "$file"
  done

  # Clean up configured backup files
  for file_path in "${BACKUP_FILES[@]}"; do
    full_path="$HOME/$file_path"
    if [[ -f "$full_path" ]]; then
      echo "Moving to trash: $full_path"
      trash-put "$full_path"
    fi
  done
}

# Parse nh arguments
NIX_BUILD_CORES=""
parse_nh_args() {
  local args_string=""
  local options_selected=()
  shift # Remove the main command

  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry | -n)
        args_string="$args_string --dry"
        options_selected+=("dry run mode")
        shift
        ;;
      --ask | -a)
        args_string="$args_string --ask"
        options_selected+=("confirmation prompts")
        shift
        ;;
      --cores)
        if [[ -n ${2:-} && $2 =~ ^[0-9]+$ ]]; then
          NIX_BUILD_CORES="$2"
          options_selected+=("limited to $2 cores")
          shift 2
        else
          print_error "--cores requires a numeric argument"
          exit 1
        fi
        ;;
      --verbose | -v)
        args_string="$args_string --verbose"
        options_selected+=("verbose output")
        shift
        ;;
      --no-nom)
        args_string="$args_string --no-nom"
        options_selected+=("nix-output-monitor disabled")
        shift
        ;;
      --)
        shift
        args_string="$args_string -- $*"
        break
        ;;
      -*)
        print_warn "Unknown flag '$1' - passing through to nh"
        args_string="$args_string $1"
        shift
        ;;
      *)
        print_error "Unexpected argument '$1'"
        exit 1
        ;;
    esac
  done

  if [[ ${#options_selected[@]} -gt 0 ]]; then
    echo "Options:" >&2
    for option in "${options_selected[@]}"; do
      echo "  - $option" >&2
    done
    echo >&2
  fi

  echo "$args_string"
}

# =============================================================================
# Commands
# =============================================================================

print_help() {
  echo -e "${BOLD}dot${NC} - NixOS Dotfiles Management CLI v$VERSION"
  echo ""
  echo -e "${BOLD}USAGE${NC}"
  echo "    dot [command] [options]"
  echo ""
  echo -e "${BOLD}SYSTEM${NC}"
  echo -e "    ${CYAN}rebuild${NC} [opts]     Rebuild NixOS system"
  echo -e "    ${CYAN}rebuild-boot${NC}       Rebuild for next boot"
  echo -e "    ${CYAN}update${NC} [opts]      Update flake inputs and rebuild"
  echo -e "    ${CYAN}cleanup${NC}            Clean backup files and old NixOS generations"
  echo -e "    ${CYAN}trim${NC}               Run fstrim for SSD"
  echo ""
  echo -e "${BOLD}CACHE${NC}"
  echo -e "    ${CYAN}cache build${NC}        Build all configs locally"
  echo -e "    ${CYAN}cache start${NC}        Start remote build on ninkear"
  echo -e "    ${CYAN}cache status${NC}       Check remote build progress"
  echo -e "    ${CYAN}cache upgrade${NC}      Run auto-upgrade (server)"
  echo ""
  echo -e "${BOLD}SERVER${NC}"
  echo -e "    ${CYAN}server rebuild${NC}     Pull and rebuild on ninkear"
  echo -e "    ${CYAN}server update${NC}      Sync local repo, update flake, and rebuild ninkear"
  echo ""
  echo -e "${BOLD}OTHER${NC}"
  echo -e "    ${CYAN}backup${NC}             Backup dotfiles to ninkear"
  echo -e "    ${CYAN}doctor${NC}             Run system health checks"
  echo ""
  echo -e "${BOLD}OPTIONS (rebuild/update)${NC}"
  echo "    --dry, -n          Show what would be done"
  echo "    --ask, -a          Ask for confirmation"
  echo "    --cores N          Limit to N CPU cores"
  echo "    --verbose, -v      Verbose output"
  echo "    --no-nom           Disable nix-output-monitor"
  echo ""
  echo -e "${BOLD}EXAMPLES${NC}"
  echo "    dot rebuild              # Rebuild system"
  echo "    dot rebuild --dry        # Preview changes"
  echo "    dot cache start          # Build cache on ninkear"
  echo ""
}

cmd_rebuild() {
  verify_hostname
  setup_sudo
  handle_backups
  ensure_ninkear_connected

  local current_hostname
  current_hostname=$(hostname)

  # Check for --low-level flag to use nixos-rebuild directly instead of nh
  local use_low_level=false
  local filtered_args=()
  for arg in "$@"; do
    if [[ "$arg" == "--low-level" ]]; then
      use_low_level=true
    else
      filtered_args+=("$arg")
    fi
  done

  local nix_jobs="${NIX_BUILD_CORES:-auto}"
  local sub_args
  sub_args=$(nix_substituter_args)

  if $use_low_level; then
    print_info "Starting NixOS rebuild (nixos-rebuild) for host: $current_hostname"
    # shellcheck disable=SC2086
    if echo "$(grep SUDO_PASSWORD "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"')" | sudo -S nixos-rebuild switch --flake "${PROJECT_DIR}?submodules=1#${current_hostname}" --max-jobs "$nix_jobs" $sub_args; then
      print_success "Rebuild finished successfully"
    else
      print_error "Rebuild failed"
      exit 1
    fi
    return
  fi

  local extra_args
  extra_args=$(parse_nh_args "${filtered_args[@]+"${filtered_args[@]}"}")

  print_info "Starting NixOS rebuild for host: $current_hostname"

  # shellcheck disable=SC2086
  if eval "nh os switch '${PROJECT_DIR}?submodules=1' --hostname '$current_hostname' $extra_args -- --max-jobs $nix_jobs $sub_args"; then
    print_success "Rebuild finished successfully"
  else
    print_error "Rebuild failed"
    exit 1
  fi
}

cmd_rebuild_boot() {
  verify_hostname
  setup_sudo
  handle_backups
  ensure_ninkear_connected

  local extra_args
  extra_args=$(parse_nh_args "$@")

  local current_hostname
  current_hostname=$(hostname)

  print_info "Starting NixOS rebuild (boot) for host: $current_hostname"
  print_info "Configuration will be activated on next reboot"

  local nix_jobs="${NIX_BUILD_CORES:-auto}"
  local sub_args
  sub_args=$(nix_substituter_args)

  # shellcheck disable=SC2086
  if eval "nh os boot '${PROJECT_DIR}?submodules=1' --hostname '$current_hostname' $extra_args -- --max-jobs $nix_jobs $sub_args"; then
    print_success "Rebuild-boot finished successfully"
    print_info "New configuration set as boot default - restart to activate"
  else
    print_error "Rebuild-boot failed"
    exit 1
  fi
}

cmd_update() {
  verify_hostname
  setup_sudo
  handle_backups
  ensure_ninkear_connected

  local current_hostname
  current_hostname=$(hostname)

  # Check for --low-level flag
  local use_low_level=false
  local filtered_args=()
  for arg in "$@"; do
    if [[ "$arg" == "--low-level" ]]; then
      use_low_level=true
    else
      filtered_args+=("$arg")
    fi
  done

  print_info "Updating flake inputs for host: $current_hostname"

  local nixpkgs_rev
  nixpkgs_rev=$(curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]')
  if [[ -z "$nixpkgs_rev" ]]; then
    print_warn "Could not fetch cached nixpkgs revision - falling back to HEAD"
    nix flake update
  else
    print_info "Latest cached nixos-unstable commit: $nixpkgs_rev"
    nix flake update
    nix flake lock --override-input nixpkgs "github:nixos/nixpkgs/$nixpkgs_rev"
    print_success "nixpkgs pinned to cached channel commit"
  fi

  local nix_jobs="${NIX_BUILD_CORES:-auto}"
  local sub_args
  sub_args=$(nix_substituter_args)

  if $use_low_level; then
    print_info "Starting NixOS rebuild (nixos-rebuild) for host: $current_hostname"
    # shellcheck disable=SC2086
    if echo "$(grep SUDO_PASSWORD "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"')" | sudo -S nixos-rebuild switch --flake "${PROJECT_DIR}?submodules=1#${current_hostname}" --max-jobs "$nix_jobs" $sub_args; then
      print_success "Update and rebuild finished successfully"
    else
      print_error "Update and rebuild failed"
      exit 1
    fi
    return
  fi

  local extra_args
  extra_args=$(parse_nh_args "${filtered_args[@]+"${filtered_args[@]}"}")

  # shellcheck disable=SC2086
  if eval "nh os switch '${PROJECT_DIR}?submodules=1' --hostname '$current_hostname' $extra_args -- --max-jobs $nix_jobs $sub_args"; then
    print_success "Update and rebuild finished successfully"
  else
    print_error "Update and rebuild failed"
    exit 1
  fi
}

cmd_backup() {
  require_private_config
  print_info "Checking SSH connectivity to $BACKUP_SERVER (via Tailscale)..."

  if ! is_ninkear_reachable; then
    print_error "Cannot connect to backup server at $BACKUP_SERVER"
    echo "Make sure:" >&2
    echo "  1. Tailscale is connected" >&2
    echo "  2. SSH key is configured correctly" >&2
    echo "  3. The server is running" >&2
    exit 1
  fi

  print_success "SSH connection successful!"
  echo ""
  print_info "Backing up dotfiles to $BACKUP_SERVER:$BACKUP_PATH..."

  ssh "$BACKUP_SERVER" "mkdir -p $BACKUP_PATH"

  rsync -avz --delete --chmod=Du+w,Fu+w \
    "$PROJECT_DIR/" \
    "$BACKUP_SERVER:$BACKUP_PATH/"

  echo ""
  print_success "Backup completed!"
  echo "Location: $BACKUP_SERVER:$BACKUP_PATH"
}

cmd_cache() {
  local subcmd="${1:-}"

  case "$subcmd" in
    build)
      # Build all configurations locally
      print_header "Building all configurations for cache"
      echo ""

      # Use max cores - 1 to keep system responsive
      local cores=$(($(nproc) - 1))
      [[ $cores -lt 1 ]] && cores=1
      print_info "Using up to $cores cores (max - 1) per build"
      echo ""

      local hosts=("laptop-82sn" "ninkear")
      local failed=()

      for host in "${hosts[@]}"; do
        print_info "Building $host..."
        # Use --max-jobs 1 to build one derivation at a time, --cores to limit cores per build
        if nix build "${PROJECT_DIR}?submodules=1#nixosConfigurations.$host.config.system.build.toplevel" --no-link --max-jobs 1 --cores "$cores"; then
          print_success "$host built successfully"
        else
          print_error "$host build failed"
          failed+=("$host")
        fi
        echo ""
      done

      if [[ ${#failed[@]} -eq 0 ]]; then
        print_success "All configurations built successfully"
      else
        print_error "Failed to build: ${failed[*]}"
        exit 1
      fi
      ;;

    start)
      # Start remote build on ninkear
      require_private_config
      local current_hostname
      current_hostname=$(hostname)
      local server_dotfiles="/home/romanv/Documents/dotfiles"

      if [[ "$current_hostname" == "ninkear" ]]; then
        print_error "This command is for laptops only. On ninkear, use 'dot cache build' directly."
        exit 1
      fi

      print_info "Checking SSH connectivity to ninkear..."

      if ! is_ninkear_reachable; then
        print_error "Cannot connect to ninkear at $BACKUP_SERVER"
        echo "Make sure Tailscale is connected and ninkear is running." >&2
        exit 1
      fi

      print_success "SSH connection successful!"
      echo ""

      print_info "Pulling latest changes on ninkear..."
      ssh -T "$BACKUP_SERVER" "cd $server_dotfiles && git pull"

      print_info "Starting cache build in background on ninkear..."
      ssh -T "$BACKUP_SERVER" "tmux kill-session -t cache-build 2>/dev/null || true; \
      tmux new-session -d -s cache-build \
      'cd $server_dotfiles && dot cache build 2>&1 | tee /tmp/cache-build.log; \
      echo \"Build finished at \$(date)\" >> /tmp/cache-build.log'"

      echo ""
      print_success "Cache build started on ninkear!"
      echo ""
      echo "You can now close this terminal. The build will continue on ninkear."
      echo ""
      echo "To check progress:  dot cache status"
      echo "To attach to build: ssh ninkear -t 'tmux attach'"
      ;;

    status)
      # Check remote build status
      require_private_config
      print_info "Checking cache build status on ninkear..."

      if ! is_ninkear_reachable; then
        print_error "Cannot connect to ninkear at $BACKUP_SERVER"
        exit 1
      fi

      if ssh "$BACKUP_SERVER" "tmux has-session -t cache-build 2>/dev/null"; then
        print_info "Build is ${YELLOW}running${NC}..."
        echo ""
        echo "--- Last 20 lines of build log ---"
        ssh "$BACKUP_SERVER" "tail -20 /tmp/cache-build.log 2>/dev/null || echo 'No log file yet'"
        echo "-----------------------------------"
        echo ""
        echo "To watch live: ssh ninkear -t 'tmux attach'"
      else
        if ssh "$BACKUP_SERVER" "test -f /tmp/cache-build.log"; then
          print_success "Build ${GREEN}completed${NC}"
          echo ""
          echo "--- Last 30 lines of build log ---"
          ssh "$BACKUP_SERVER" "tail -30 /tmp/cache-build.log"
          echo "-----------------------------------"
        else
          print_info "No build in progress or recent build log found."
          echo "Start a build with: dot cache start"
        fi
      fi
      ;;

    upgrade)
      # Run auto-upgrade service (server only)
      print_info "Starting auto-upgrade service in background..."
      sudo systemctl start nixos-upgrade.service --no-block
      print_success "Auto-upgrade started. Monitor with: journalctl -fu nixos-upgrade"
      ;;

    *)
      echo "Usage: dot cache [build|start|status|upgrade]"
      echo ""
      echo "Subcommands:"
      echo "  build    Build all configs locally for binary cache"
      echo "  start    Start remote build on ninkear (laptop only)"
      echo "  status   Check remote build progress"
      echo "  upgrade  Run auto-upgrade service (server only)"
      exit 1
      ;;
  esac
}

cmd_server() {
  local subcmd="${1:-}"
  local server_host="${BACKUP_SERVER:-ninkear}"
  local server_dotfiles="/home/romanv/Documents/dotfiles"
  local server_backup_dotfiles="${BACKUP_PATH:-/home/romanv/backup/dotfiles}"
  local private_repo="$PROJECT_DIR/private"

  case "$subcmd" in
    rebuild)
      print_info "Checking SSH connectivity to ninkear..."

      if ! is_ninkear_reachable "$server_host"; then
        print_error "Cannot connect to ninkear at $server_host"
        echo "Make sure Tailscale is connected and ninkear is running." >&2
        exit 1
      fi

      print_success "SSH connection successful!"
      echo ""

      print_info "Pulling latest changes and rebuilding on ninkear..."
      ssh -t "$server_host" "cd \"$server_dotfiles\" && git pull --ff-only && dot rebuild --low-level"

      print_success "Server rebuild complete!"
      ;;

    update)
      print_info "Checking SSH connectivity to ninkear..."

      if ! is_ninkear_reachable "$server_host"; then
        print_error "Cannot connect to ninkear at $server_host"
        echo "Make sure Tailscale is connected and ninkear is running." >&2
        exit 1
      fi

      print_success "SSH connection successful!"
      echo ""

      print_info "Pulling latest changes from dotfiles repository..."
      git -C "$PROJECT_DIR" pull --ff-only

      if [[ -d "$private_repo" ]] && git -C "$private_repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print_info "Pulling latest changes from private repository..."
        local private_branch
        private_branch="$(git -C "$private_repo" branch --show-current 2>/dev/null || true)"

        if [[ -n "$private_branch" ]]; then
          git -C "$private_repo" pull --ff-only origin "$private_branch"
        else
          git -C "$PROJECT_DIR" submodule update --init --recursive --remote private
          print_info "private repository updated via submodule remote tracking"
        fi

        commit_repo_if_needed "$private_repo" "chore(private): checkpoint before server update" "private repository"
      else
        print_info "private/ repository not found - skipping private pull and commit"
      fi

      commit_repo_if_needed "$PROJECT_DIR" "chore(sync): checkpoint before server update" "dotfiles repository"
      echo ""

      print_info "Syncing current folder to ninkear:$server_backup_dotfiles..."
      ssh "$server_host" "mkdir -p \"$server_backup_dotfiles\""

      rsync -avz --delete --chmod=Du+w,Fu+w \
        "$PROJECT_DIR/" \
        "$server_host:$server_backup_dotfiles/"

      print_info "Ensuring ownership is romanv on ninkear..."
      ssh "$server_host" "set -e; \
      non_owned=\$(find \"$server_backup_dotfiles\" -mindepth 1 ! -user romanv -print -quit); \
      if [ -n \"\$non_owned\" ]; then \
        owner_group=\$(id -gn romanv 2>/dev/null || echo romanv); \
        if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then \
          sudo chown -R romanv:\$owner_group \"$server_backup_dotfiles\"; \
        else \
          echo '[ERROR] Files are not owned by romanv and passwordless sudo is unavailable.' >&2; \
          exit 1; \
        fi; \
      fi"

      print_info "Updating flake to latest cached nixpkgs and rebuilding on ninkear..."
      ssh -t "$server_host" "cd \"$server_backup_dotfiles\" && \
      NIXPKGS_REV=\$(curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]') && \
      echo \"[INFO] Latest cached nixos-unstable commit: \$NIXPKGS_REV\" && \
      nix flake update && \
      nix flake lock --override-input nixpkgs \"github:nixos/nixpkgs/\$NIXPKGS_REV\" && \
      echo \"[INFO] nixpkgs pinned to cached channel commit\" && \
      dot rebuild --low-level && \
      if git diff --quiet flake.lock 2>/dev/null; then \
        echo 'No flake.lock changes to commit'; \
      else \
        git add flake.lock && \
        git commit -m 'chore: update flake inputs' && \
        git push origin main && \
        echo 'Committed and pushed flake.lock changes'; \
      fi"

      print_success "Server update complete!"
      ;;

    *)
      echo "Usage: dot server [rebuild|update]"
      echo ""
      echo "Subcommands:"
      echo "  rebuild    Pull latest changes and rebuild ninkear"
      echo "  update     Pull local repos, sync to ninkear backup, update and rebuild"
      exit 1
      ;;
  esac
}

cmd_cleanup() {
  # Clean up home-manager backup files from rebuilds
  print_info "Moving backup files to trash..."
  local backup_count=0

  # Move .hm-bak files to trash (excluding trash directory)
  while IFS= read -r -d '' file; do
    echo "  Moving to trash: $file"
    trash-put "$file"
    ((backup_count++)) || true
  done < <(find "$HOME" -maxdepth 5 -name "*.hm-bak" -type f -not -path "$HOME/.local/share/Trash/*" -print0 2>/dev/null)

  # Move timestamped backup files to trash (e.g., .claude.json.backup.1770386327310)
  while IFS= read -r -d '' file; do
    echo "  Moving to trash: $file"
    trash-put "$file"
    ((backup_count++)) || true
  done < <(find "$HOME" -maxdepth 5 -name "*.backup.[0-9]*" -type f -not -path "$HOME/.local/share/Trash/*" -print0 2>/dev/null)

  # Move other backup patterns to trash
  for file_path in "${BACKUP_FILES[@]}"; do
    full_path="$HOME/$file_path"
    if [[ -f "$full_path" ]]; then
      echo "  Moving to trash: $full_path"
      trash-put "$full_path"
      ((backup_count++)) || true
    fi
  done

  if [[ $backup_count -gt 0 ]]; then
    print_success "Moved $backup_count backup file(s) to trash"
  else
    print_info "No backup files found"
  fi
  echo ""

  # Clean old NixOS generations and garbage collect
  print_info "Cleaning old NixOS generations..."
  local use_low_level=false
  for arg in "$@"; do
    [[ "$arg" == "--low-level" ]] && use_low_level=true
  done
  if $use_low_level; then
    echo "$(grep SUDO_PASSWORD "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"')" | sudo -S nix-collect-garbage --delete-older-than 7d
  else
    nh clean all
  fi
  print_success "System cleanup complete"
}

cmd_trim() {
  echo "Running 'sudo fstrim -v /' may take a few minutes."
  read -rp "Continue? (y/N) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Running fstrim..."
    sudo fstrim -v /
    print_success "fstrim complete."
  else
    echo "Trim operation cancelled."
  fi
}

cmd_doctor() {
  print_header "System Health Checks"
  echo ""

  local checks_passed=0
  local checks_failed=0
  local checks_warned=0

  check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((checks_passed++))
  }

  check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((checks_failed++))
  }

  check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((checks_warned++))
  }

  check_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
  }

  # System Checks
  echo -e "${BLUE}=== System Checks ===${NC}"

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    check_info "NixOS Version: $VERSION"
  fi

  check_info "Kernel: $(uname -r)"

  local current_hostname
  current_hostname=$(hostname)
  if [[ -d "$PROJECT_DIR/hosts/$current_hostname" ]]; then
    check_pass "Host configuration exists for '$current_hostname'"
  else
    check_fail "Host configuration missing for '$current_hostname'"
  fi

  echo ""
  echo -e "${BLUE}=== Service Checks ===${NC}"

  local failed_system
  failed_system=$(systemctl --system --failed --no-legend 2>/dev/null | wc -l)
  local failed_user
  failed_user=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)

  if [[ "$failed_system" -eq 0 ]]; then
    check_pass "No failed system services"
  else
    check_fail "$failed_system failed system service(s)"
    systemctl --system --failed --no-legend 2>/dev/null | while read -r line; do
      echo "       - $line"
    done
  fi

  if [[ "$failed_user" -eq 0 ]]; then
    check_pass "No failed user services"
  else
    check_fail "$failed_user failed user service(s)"
    systemctl --user --failed --no-legend 2>/dev/null | while read -r line; do
      echo "       - $line"
    done
  fi

  echo ""
  echo -e "${BLUE}=== Disk Checks ===${NC}"

  local root_usage
  root_usage=$(df / --output=pcent | tail -1 | tr -d ' %')
  if [[ "$root_usage" -lt 80 ]]; then
    check_pass "Root filesystem usage: $root_usage%"
  elif [[ "$root_usage" -lt 90 ]]; then
    check_warn "Root filesystem usage: $root_usage% (consider cleanup)"
  else
    check_fail "Root filesystem usage: $root_usage% (critically low!)"
  fi

  local nix_store_size
  nix_store_size=$(du -sh /nix/store 2>/dev/null | cut -f1 || echo "unknown")
  check_info "Nix store size: $nix_store_size"

  local gen_count
  gen_count=$(nix profile history --profile /nix/var/nix/profiles/system 2>/dev/null | grep -c "Version" || echo "0")
  if [[ "$gen_count" -gt 10 ]]; then
    check_warn "System has $gen_count generations (consider 'dot cleanup')"
  else
    check_pass "System generations: $gen_count"
  fi

  echo ""
  echo -e "${BLUE}=== Network Checks ===${NC}"

  if curl -s --max-time 5 https://nixos.org >/dev/null 2>&1; then
    check_pass "Internet connectivity OK"
  else
    check_warn "Cannot reach nixos.org (may be offline)"
  fi

  if systemctl is-active --quiet firewall 2>/dev/null || systemctl is-active --quiet iptables 2>/dev/null; then
    check_pass "Firewall is active"
  else
    check_info "Firewall status unknown"
  fi

  echo ""
  echo -e "${BLUE}=== Security Checks ===${NC}"

  if systemctl is-active --quiet sshd 2>/dev/null; then
    check_pass "SSH daemon is running"
  fi

  echo ""
  echo -e "${BLUE}=== Git Repository Checks ===${NC}"

  cd "$PROJECT_DIR" || exit 1
  if git diff --quiet 2>/dev/null; then
    check_pass "No uncommitted changes in dotfiles"
  else
    check_warn "Uncommitted changes in dotfiles"
  fi

  git fetch origin --quiet 2>/dev/null || true
  local local_hash
  local_hash=$(git rev-parse HEAD 2>/dev/null)
  local remote_hash
  remote_hash=$(git rev-parse origin/main 2>/dev/null || echo "")

  if [[ -n "$remote_hash" ]]; then
    if [[ "$local_hash" == "$remote_hash" ]]; then
      check_pass "Dotfiles up to date with remote"
    else
      local ahead
      ahead=$(git rev-list origin/main..HEAD --count 2>/dev/null || echo "0")
      local behind
      behind=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
      if [[ "$ahead" -gt 0 ]]; then
        check_info "Dotfiles $ahead commit(s) ahead of remote"
      fi
      if [[ "$behind" -gt 0 ]]; then
        check_warn "Dotfiles $behind commit(s) behind remote"
      fi
    fi
  fi

  echo ""
  echo "========================================"
  echo -e "Results: ${GREEN}$checks_passed passed${NC}, ${YELLOW}$checks_warned warnings${NC}, ${RED}$checks_failed failed${NC}"

  if [[ "$checks_failed" -gt 0 ]]; then
    exit 1
  fi
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
  if [[ $# -eq 0 ]]; then
    print_help
    exit 0
  fi

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
    cache)
      shift
      cmd_cache "${1:-}"
      ;;
    server)
      shift
      cmd_server "${1:-}"
      ;;
    cleanup)
      shift
      cmd_cleanup "$@"
      ;;
    backup)
      cmd_backup
      ;;
    doctor)
      cmd_doctor
      ;;
    trim)
      cmd_trim
      ;;
    help | --help | -h)
      print_help
      ;;
    *)
      print_error "Unknown command: $1"
      echo ""
      print_help
      exit 1
      ;;
  esac
}

main "$@"
