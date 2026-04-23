{ pkgs }:
pkgs.writeShellApplication {
  name = "dot";

  runtimeInputs = with pkgs; [
    coreutils
    curl
    findutils
    gawk
    git
    gnugrep
    gnused
    iputils
    jq
    nix
    openssh
    rsync
    tmux
    trash-cli
  ];

  text = ''
    set -euo pipefail

    resolve_project_dir() {
      if [[ -n "''${DOT_PROJECT_DIR:-}" ]]; then
        printf '%s\n' "$DOT_PROJECT_DIR"
        return
      fi

      local git_root
      git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
      if [[ -n "$git_root" && -f "$git_root/flake.nix" ]]; then
        printf '%s\n' "$git_root"
        return
      fi

      if [[ -f "$PWD/flake.nix" ]]; then
        printf '%s\n' "$PWD"
        return
      fi

      echo "dot: set DOT_PROJECT_DIR or run from the dotfiles repository" >&2
      exit 1
    }

    PROJECT_DIR=$(resolve_project_dir)
    BACKUP_SERVER=""
    BACKUP_PATH=""

    # shellcheck source=/dev/null
    [[ -f "$PROJECT_DIR/private/dot-config.sh" ]] && source "$PROJECT_DIR/private/dot-config.sh"

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

    print_success() { echo -e "''${GREEN}[OK]''${NC} $1"; }
    print_error() { echo -e "''${RED}[ERROR]''${NC} $1" >&2; }
    print_warn() { echo -e "''${YELLOW}[WARN]''${NC} $1"; }
    print_info() { echo -e "''${BLUE}[INFO]''${NC} $1"; }

    project_flake_ref() {
      local ref="$PROJECT_DIR"
      if git -C "$PROJECT_DIR" submodule status private 2>/dev/null | grep -qv "^-"; then
        ref="$PROJECT_DIR?submodules=1"
      fi
      printf '%s\n' "$ref"
    }

    list_hosts() {
      nix eval --raw "$(project_flake_ref)#nixosConfigurations" \
        --apply 'configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)'
    }

    require_private_config() {
      if [[ -z "$BACKUP_SERVER" ]]; then
        print_error "Private config not found. Init private/ submodule first."
        exit 1
      fi
    }

    get_sudo_pass() {
      grep SUDO_PASSWORD "$PROJECT_DIR/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || true
    }

    run_sudo() {
      local pass
      local sudo_bin="/run/wrappers/bin/sudo"

      if [[ ! -x "$sudo_bin" ]]; then
        sudo_bin=$(command -v sudo)
      fi

      pass=$(get_sudo_pass)
      if [[ -n "$pass" ]]; then
        echo "$pass" | "$sudo_bin" -S "$@"
      else
        "$sudo_bin" "$@"
      fi
    }

    is_ninkear_reachable() {
      ssh -o ConnectTimeout=3 -o BatchMode=yes "''${1:-$BACKUP_SERVER}" "exit" 2>/dev/null
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
      local h hosts
      h=$(hostname)
      hosts=$(list_hosts)

      if ! grep -Fxq "$h" <<<"$hosts"; then
        print_error "Host '$h' not found in flake nixosConfigurations"
        exit 1
      fi
    }

    handle_backups() {
      while IFS= read -r -d $'\0' file; do
        trash-put "$file"
      done < <(find "$HOME" -maxdepth 5 \( -name "*.hm-bak" -o -name "*.backup.[0-9]*" \) \
        -type f -not -path "$HOME/.local/share/Trash/*" -print0 2>/dev/null)

      for f in "''${BACKUP_FILES[@]}"; do
        if [[ -f "$HOME/$f" ]]; then
          trash-put "$HOME/$f"
        fi
      done
    }

    do_rebuild() {
      local action="$1" plain="$2"
      shift 2

      local host flake_ref prev_system
      host=$(hostname)

      verify_hostname
      handle_backups
      ensure_ninkear_connected
      build_substituter_args

      flake_ref="$(project_flake_ref)#$host"
      prev_system=""
      [[ "$action" == "switch" && "$plain" == "false" ]] && prev_system=$(readlink -f /run/current-system 2>/dev/null || true)

      print_info "nixos-rebuild $action -> $host"
      if [[ "$plain" == "false" ]] && command -v nom >/dev/null 2>&1; then
        run_sudo nixos-rebuild "$action" --flake "$flake_ref" "''${_sub_args[@]}" "$@" 2>&1 | nom
      else
        run_sudo nixos-rebuild "$action" --flake "$flake_ref" "''${_sub_args[@]}" "$@"
      fi

      if [[ -n "$prev_system" ]] && command -v nvd >/dev/null 2>&1; then
        nvd diff "$prev_system" /run/current-system
      fi
    }

    cmd_rebuild() {
      local dry=false plain=false extra=()

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --dry|-n)
            dry=true
            shift
            ;;
          --plain)
            plain=true
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
        do_rebuild dry-activate "$plain" "''${extra[@]}"
        print_success "Dry-activate complete"
      else
        do_rebuild switch "$plain" "''${extra[@]}"
        print_success "Rebuild complete"
      fi
    }

    cmd_rebuild_boot() {
      do_rebuild boot false
      print_success "Rebuild complete - activate on next boot"
    }

    cmd_update() {
      local nixpkgs_rev

      print_info "Updating flake inputs..."
      nixpkgs_rev=$(curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]')

      (
        cd "$PROJECT_DIR"
        if [[ -n "$nixpkgs_rev" ]]; then
          nix flake update
          nix flake lock --override-input nixpkgs "github:nixos/nixpkgs/$nixpkgs_rev"
          print_success "nixpkgs pinned to cached channel commit"
        else
          print_warn "Could not fetch cached nixpkgs revision - updating to HEAD"
          nix flake update
        fi
      )

      do_rebuild switch false
      print_success "Update and rebuild complete"
    }

    cmd_cleanup() {
      print_info "Cleaning up backup files..."
      handle_backups
      print_info "Collecting garbage (older than 7 days)..."
      run_sudo nix-collect-garbage --delete-older-than 7d
      print_success "Cleanup complete"
    }

    cmd_backup() {
      require_private_config
      if ! is_ninkear_reachable; then
        print_error "Cannot connect to $BACKUP_SERVER"
        exit 1
      fi

      print_info "Backing up dotfiles to $BACKUP_SERVER:$BACKUP_PATH..."
      # shellcheck disable=SC2029
      ssh "$BACKUP_SERVER" "mkdir -p $BACKUP_PATH"
      rsync -avz --delete --chmod=Du+w,Fu+w "$PROJECT_DIR/" "$BACKUP_SERVER:$BACKUP_PATH/"
      print_success "Backup complete -> $BACKUP_SERVER:$BACKUP_PATH"
    }

    cmd_cache() {
      local subcmd="''${1:-}"
      local server_repo="''${BACKUP_PATH:-/home/romanv/backup/dotfiles}"

      case "$subcmd" in
        build)
          local flake_ref cores
          local -a failed hosts

          flake_ref=$(project_flake_ref)
          cores=$(( $(nproc) - 1 ))
          [[ $cores -lt 1 ]] && cores=1

          mapfile -t hosts < <(list_hosts)
          if [[ ''${#hosts[@]} -eq 0 ]]; then
            print_error "No nixosConfigurations found"
            exit 1
          fi

          failed=()
          for host in "''${hosts[@]}"; do
            print_info "Building $host..."
            if nix build "$flake_ref#nixosConfigurations.$host.config.system.build.toplevel" --no-link --max-jobs 1 --cores "$cores"; then
              print_success "$host built"
            else
              print_error "$host failed"
              failed+=("$host")
            fi
          done

          if [[ ''${#failed[@]} -gt 0 ]]; then
            print_error "Failed: ''${failed[*]}"
            exit 1
          fi

          print_success "All configurations built"
          ;;
        start)
          require_private_config
          if [[ "$(hostname)" == "ninkear" ]]; then
            print_error "Run 'dot cache build' directly on ninkear"
            exit 1
          fi

          is_ninkear_reachable || {
            print_error "Cannot connect to ninkear"
            exit 1
          }

          # shellcheck disable=SC2029
          ssh -T "$BACKUP_SERVER" "tmux kill-session -t cache-build 2>/dev/null || true; tmux new-session -d -s cache-build 'cd $server_repo && dot cache build 2>&1 | tee /tmp/cache-build.log'"
          print_success "Cache build started on ninkear"
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
          elif ssh "$BACKUP_SERVER" "test -f /tmp/cache-build.log"; then
            print_success "Build completed"
            ssh "$BACKUP_SERVER" "tail -30 /tmp/cache-build.log"
          else
            print_info "No build in progress. Start with: dot cache start"
          fi
          ;;
        *)
          print_error "Usage: dot cache [build|start|status]"
          exit 1
          ;;
      esac
    }

    cmd_server() {
      local subcmd="''${1:-}"
      local server_host="''${BACKUP_SERVER:-ninkear}"
      local server_repo="''${BACKUP_PATH:-/home/romanv/backup/dotfiles}"

      case "$subcmd" in
        rebuild)
          is_ninkear_reachable "$server_host" || {
            print_error "Cannot connect to ninkear"
            exit 1
          }

          print_info "Pulling and rebuilding on ninkear..."
          # shellcheck disable=SC2029
          ssh -t "$server_host" "cd \"$server_repo\" && dot rebuild"
          print_success "Server rebuild complete"
          ;;
        update)
          require_private_config
          is_ninkear_reachable "$server_host" || {
            print_error "Cannot connect to ninkear"
            exit 1
          }

           print_info "Syncing to ninkear:$server_repo..."
           # shellcheck disable=SC2029
           ssh "$server_host" "mkdir -p \"$server_repo\""
          # shellcheck disable=SC2029
          ssh "$server_host" "set -e; non_owned=\$(find \"$server_repo\" -mindepth 1 ! -user romanv -print -quit); if [ -n \"\$non_owned\" ]; then owner_group=\$(id -gn romanv 2>/dev/null || echo romanv); sudo chown -R romanv:\$owner_group \"$server_repo\"; fi"
          rsync -avz --delete --chmod=Du+w,Fu+w "$PROJECT_DIR/" "$server_host:$server_repo/"

          print_info "Updating flake and rebuilding on ninkear..."
          # shellcheck disable=SC2029
          ssh -t "$server_host" "cd \"$server_repo\" && NIXPKGS_REV=\$(curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]') && nix flake update && if [ -n \"\$NIXPKGS_REV\" ]; then nix flake lock --override-input nixpkgs \"github:nixos/nixpkgs/\$NIXPKGS_REV\"; fi && dot rebuild"
          print_success "Server update complete"
          ;;
        *)
          print_error "Usage: dot server [rebuild|update]"
          exit 1
          ;;
      esac
    }

    print_help() {
      echo -e "''${BOLD}dot''${NC} - flake-native dotfiles CLI"
      echo
      echo -e "  ''${CYAN}rebuild''${NC} [--dry] [--plain] [--cores N]"
      echo -e "  ''${CYAN}rebuild-boot''${NC}"
      echo -e "  ''${CYAN}update''${NC}"
      echo -e "  ''${CYAN}cleanup''${NC}"
      echo -e "  ''${CYAN}backup''${NC}"
      echo -e "  ''${CYAN}cache build|start|status''${NC}"
      echo -e "  ''${CYAN}server rebuild|update''${NC}"
    }

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
        cleanup)
          cmd_cleanup
          ;;
        backup)
          cmd_backup
          ;;
        cache)
          shift
          cmd_cache "''${1:-}"
          ;;
        server)
          shift
          cmd_server "''${1:-}"
          ;;
        help|--help|-h)
          print_help
          ;;
        *)
          print_error "Unknown command: $1"
          echo
          print_help
          exit 1
          ;;
      esac
    }

    main "$@"
  '';
}
