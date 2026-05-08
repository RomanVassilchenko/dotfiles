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
    jq
    nix
    openssh
    rsync
    tmux
    trash-cli
    util-linux
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
    SERVER_REPO_PATH=""

    # shellcheck source=/dev/null
    [[ -f "$PROJECT_DIR/private/dot-config.sh" ]] && source "$PROJECT_DIR/private/dot-config.sh"
    # shellcheck source=/dev/null
    [[ -f "$PROJECT_DIR/private/dot-commands.sh" ]] && source "$PROJECT_DIR/private/dot-commands.sh"

    BACKUP_FILES=(
      ".config/mimeapps.list.hm-bak"
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

    _sub_args=()
    build_substituter_args() {
      _sub_args=(
        --no-write-lock-file
        --option connect-timeout 3
        --option substituters "https://cache.nixos.org https://nix-community.cachix.org https://cache.numtide.com"
      )
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
      for f in "''${BACKUP_FILES[@]}"; do
        if [[ -f "$HOME/$f" ]]; then
          trash-put "$HOME/$f"
        fi
      done

      if [[ "''${1:-known}" == "all" ]]; then
        while IFS= read -r -d $'\0' file; do
          trash-put "$file"
        done < <(find "$HOME" -maxdepth 5 \( -name "*.hm-bak" -o -name "*.backup.[0-9]*" \) \
          -type f -not -path "$HOME/.local/share/Trash/*" -print0 2>/dev/null)
      fi
    }

    do_rebuild() {
      local action="$1" plain="$2"
      shift 2

      local host flake_ref prev_system needs_sudo
      host=$(hostname)

      verify_hostname
      handle_backups
      build_substituter_args

      flake_ref="$(project_flake_ref)#$host"
      prev_system=""
      [[ "$action" == "switch" && "$plain" == "false" ]] && prev_system=$(readlink -f /run/current-system 2>/dev/null || true)
      needs_sudo=true
      case "$action" in
        build|dry-build|dry-run)
          needs_sudo=false
          ;;
      esac

      print_info "nixos-rebuild $action -> $host"
      if [[ "$plain" == "false" ]] && command -v nom >/dev/null 2>&1; then
        if [[ "$needs_sudo" == "true" ]]; then
          run_sudo nixos-rebuild "$action" --flake "$flake_ref" "''${_sub_args[@]}" "$@" 2>&1 | nom
        else
          nixos-rebuild "$action" --flake "$flake_ref" "''${_sub_args[@]}" "$@" 2>&1 | nom
        fi
      else
        if [[ "$needs_sudo" == "true" ]]; then
          run_sudo nixos-rebuild "$action" --flake "$flake_ref" "''${_sub_args[@]}" "$@"
        else
          nixos-rebuild "$action" --flake "$flake_ref" "''${_sub_args[@]}" "$@"
        fi
      fi

      if [[ -n "$prev_system" ]] && command -v nvd >/dev/null 2>&1; then
        nvd diff "$prev_system" /run/current-system
      fi
    }

    cmd_rebuild() {
      local action="switch" plain=false extra=()

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --dry|-n)
            action="dry-build"
            shift
            ;;
          --dry-activate)
            action="dry-activate"
            shift
            ;;
          --build)
            action="build"
            shift
            ;;
          --test)
            action="test"
            shift
            ;;
          --plain)
            plain=true
            shift
            ;;
          --cores)
            if [[ $# -lt 2 ]]; then
              print_error "--cores requires a value"
              exit 1
            fi
            extra+=(--cores "$2")
            shift 2
            ;;
          --jobs)
            if [[ $# -lt 2 ]]; then
              print_error "--jobs requires a value"
              exit 1
            fi
            extra+=(--max-jobs "$2")
            shift 2
            ;;
          *)
            print_error "Unknown option: $1"
            exit 1
            ;;
        esac
      done

      do_rebuild "$action" "$plain" "''${extra[@]}"
      print_success "Rebuild $action complete"
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
      local nh_bin

      print_info "Cleaning up backup files..."
      handle_backups all
      print_info "Collecting garbage (older than 7 days)..."
      if nh_bin=$(command -v nh 2>/dev/null); then
        run_sudo "$nh_bin" clean all --keep-since 7d --keep 5
      else
        run_sudo nix-collect-garbage --delete-older-than 7d
      fi
      print_info "Optimising Nix store..."
      run_sudo nix store optimise
      print_success "Cleanup complete"
    }

    cmd_doctor() {
      print_info "Checking host configuration..."
      verify_hostname
      print_success "Host is present in flake"

      print_info "Checking flake metadata..."
      nix flake metadata "$(project_flake_ref)" >/dev/null
      print_success "Flake metadata evaluates"

      if git -C "$PROJECT_DIR" diff --quiet && git -C "$PROJECT_DIR" diff --cached --quiet; then
        print_success "Git worktree is clean"
      else
        print_warn "Git worktree has local changes"
      fi

      df -h /nix/store
    }

    cmd_validate_fast() {
      print_info "Parsing tracked Nix files..."
      (
        cd "$PROJECT_DIR"
        git ls-files '*.nix' | while IFS= read -r file; do
          nix-instantiate --parse "$file" >/dev/null
        done
      )

      if [[ -x "$PROJECT_DIR/private/check.sh" ]]; then
        print_info "Running private validation..."
        "$PROJECT_DIR/private/check.sh"
      fi

      print_success "Fast validation passed"
    }

    cmd_validate() {
      local mode="''${1:-full}"

      case "$mode" in
        fast)
          cmd_validate_fast
          ;;
        full|flake)
          cmd_validate_fast
          print_info "Evaluating flake..."
          (
            cd "$PROJECT_DIR"
            nix flake check --no-build
          )
          print_success "Validation passed"
          ;;
        *)
          print_error "Usage: dot validate [fast|full|flake]"
          exit 1
          ;;
      esac
    }

    cmd_trim() {
      local fstrim_bin

      fstrim_bin=$(command -v fstrim)
      print_info "Trimming mounted filesystems..."
      run_sudo "$fstrim_bin" -av
      print_success "Trim complete"
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

    cmd_server() {
      local subcmd="''${1:-}"
      local server_host="''${BACKUP_SERVER:-ninkear}"
      local server_repo="''${SERVER_REPO_PATH:-/home/romanv/dotfiles}"

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
      echo -e "  ''${CYAN}rebuild''${NC} [--dry|--dry-activate|--build|--test] [--plain] [--cores N] [--jobs N]"
      echo -e "  ''${CYAN}rebuild-boot''${NC}"
      echo -e "  ''${CYAN}update''${NC}"
      echo -e "  ''${CYAN}validate''${NC} [fast|full|flake]"
      echo -e "  ''${CYAN}cleanup''${NC}"
      echo -e "  ''${CYAN}backup''${NC}"
      echo -e "  ''${CYAN}server rebuild|update''${NC}"
      echo -e "  ''${CYAN}doctor''${NC}"
      echo -e "  ''${CYAN}trim''${NC}"
      if declare -F dot_private_help >/dev/null 2>&1; then
        dot_private_help
      fi
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
        validate)
          shift
          cmd_validate "''${1:-full}"
          ;;
        cleanup)
          shift
          cmd_cleanup
          ;;
        backup)
          shift
          cmd_backup
          ;;
        server)
          shift
          cmd_server "''${1:-}"
          ;;
        doctor)
          shift
          cmd_doctor
          ;;
        trim)
          shift
          cmd_trim
          ;;
        help|--help|-h)
          print_help
          ;;
        *)
          if declare -F dot_private_handle >/dev/null 2>&1; then
            private_status=0
            dot_private_handle "$@" || private_status=$?
            if [[ "$private_status" -ne 1 ]]; then
              exit "$private_status"
            fi
          fi
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
