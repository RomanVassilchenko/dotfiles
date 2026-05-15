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
    PRIVATE_CONFIG_PRESENT=false

    # shellcheck source=/dev/null
    if [[ -f "$PROJECT_DIR/private/dot-config.sh" ]]; then
      PRIVATE_CONFIG_PRESENT=true
      source "$PROJECT_DIR/private/dot-config.sh"
    fi
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
      if [[ "$PRIVATE_CONFIG_PRESENT" != "true" ]]; then
        print_error "Private config not found. Init private/ submodule first."
        return 1
      fi
    }

    get_sudo_bin() {
      local sudo_bin="/run/wrappers/bin/sudo"

      if [[ ! -x "$sudo_bin" ]]; then
        sudo_bin=$(command -v sudo)
      fi

      printf '%s\n' "$sudo_bin"
    }

    ensure_sudo_session() {
      local sudo_bin
      sudo_bin=$(get_sudo_bin)

      print_info "Requesting sudo credentials..."
      if ! "$sudo_bin" -v; then
        print_error "sudo authentication failed"
        return 1
      fi
    }

    run_sudo() {
      local sudo_bin
      sudo_bin=$(get_sudo_bin)

      "$sudo_bin" "$@"
    }

    is_remote_host_reachable() {
      ssh -o ConnectTimeout=3 -o BatchMode=yes "''${1:-$BACKUP_SERVER}" "exit" 2>/dev/null
    }

    trim_trailing_slash() {
      local path="$1"

      if [[ "$path" != "/" ]]; then
        path="''${path%/}"
      fi

      printf '%s\n' "$path"
    }

    require_config_value() {
      local name="$1"
      local value="$2"

      if [[ -z "$value" ]]; then
        print_error "$name is not configured in private/dot-config.sh"
        return 1
      fi
    }

    require_absolute_path() {
      local name="$1"
      local path="$2"

      if [[ "$path" != /* ]]; then
        print_error "$name must be an absolute path, got: $path"
        return 1
      fi
    }

    require_safe_target_path() {
      local name="$1"
      local normalized_path
      normalized_path=$(trim_trailing_slash "$2")

      require_absolute_path "$name" "$normalized_path"

      case "$normalized_path" in
        /|/home|"/home/$USER"|"$HOME"|/root|/etc|/nix|/nix/store|/tmp|/var)
          print_error "$name points to an unsafe target path: $normalized_path"
          return 1
          ;;
      esac
    }

    require_distinct_target_paths() {
      local left_name="$1"
      local left_path right_name right_path
      left_path=$(trim_trailing_slash "$2")
      right_name="$3"
      right_path=$(trim_trailing_slash "$4")

      if [[ "$left_path" == "$right_path" ]]; then
        print_error "$left_name and $right_name must not point to the same path"
        return 1
      fi

      case "$left_path" in
        "$right_path"/*)
          print_error "$left_name must not be nested inside $right_name"
          return 1
          ;;
      esac

      case "$right_path" in
        "$left_path"/*)
          print_error "$right_name must not be nested inside $left_name"
          return 1
          ;;
      esac
    }

    validate_remote_config_shape() {
      require_private_config
      require_config_value "BACKUP_SERVER" "$BACKUP_SERVER"
      require_config_value "BACKUP_PATH" "$BACKUP_PATH"
      require_config_value "SERVER_REPO_PATH" "$SERVER_REPO_PATH"
      require_safe_target_path "BACKUP_PATH" "$BACKUP_PATH"
      require_safe_target_path "SERVER_REPO_PATH" "$SERVER_REPO_PATH"
      require_distinct_target_paths "BACKUP_PATH" "$BACKUP_PATH" "SERVER_REPO_PATH" "$SERVER_REPO_PATH"
    }

    require_remote_host() {
      local host="$1"

      if ! is_remote_host_reachable "$host"; then
        print_error "Cannot connect to $host"
        return 1
      fi
    }

    run_remote_check() {
      local host="$1"
      local description="$2"
      local command="$3"

      # shellcheck disable=SC2029
      if ! ssh "$host" "$command"; then
        print_error "$description"
        return 1
      fi
    }

    require_remote_directory_ready() {
      local host="$1"
      local path="$2"
      local label="$3"
      local remote_path

      remote_path=$(trim_trailing_slash "$path")
      run_remote_check "$host" "$label is missing or not writable: $remote_path" \
        "test -d \"$remote_path\" && test -w \"$remote_path\""
      run_remote_check "$host" "$label is not owned by the remote user: $remote_path" \
        "test -O \"$remote_path\""
      run_remote_check "$host" "$label contains files not owned by the remote user: $remote_path" \
        "test -z \"\$(find \"$remote_path\" -mindepth 1 ! -user \"\$(id -un)\" -print -quit 2>/dev/null)\""
    }

    require_remote_server_repo_ready() {
      local host="$1"
      local remote_path

      remote_path=$(trim_trailing_slash "$SERVER_REPO_PATH")
      require_remote_directory_ready "$host" "$remote_path" "Remote repo path"
      run_remote_check "$host" "Remote repo is missing flake.nix: $remote_path" \
        "test -f \"$remote_path/flake.nix\""
      run_remote_check "$host" "Remote repo is missing .git metadata: $remote_path" \
        "test -d \"$remote_path/.git\""
      run_remote_check "$host" "Remote dot command is not available on $host" \
        "command -v dot >/dev/null"
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
        return 1
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
      needs_sudo=true
      case "$action" in
        build|dry-build|dry-run)
          needs_sudo=false
          ;;
      esac

      verify_hostname
      build_substituter_args
      if [[ "$needs_sudo" == "true" ]]; then
        ensure_sudo_session
      fi
      handle_backups

      flake_ref="$(project_flake_ref)#$host"
      prev_system=""
      [[ "$action" == "switch" && "$plain" == "false" ]] && prev_system=$(readlink -f /run/current-system 2>/dev/null || true)

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
      verify_hostname
      nix flake metadata "$(project_flake_ref)" >/dev/null
      ensure_sudo_session
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

      ensure_sudo_session
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
      local failed=0

      print_info "Checking host configuration..."
      if verify_hostname; then
        print_success "Host is present in flake"
      else
        failed=1
      fi

      print_info "Checking flake metadata..."
      if nix flake metadata "$(project_flake_ref)" >/dev/null; then
        print_success "Flake metadata evaluates"
      else
        failed=1
      fi

      if git -C "$PROJECT_DIR" diff --quiet && git -C "$PROJECT_DIR" diff --cached --quiet; then
        print_success "Git worktree is clean"
      else
        print_warn "Git worktree has local changes"
      fi

      if [[ "$PRIVATE_CONFIG_PRESENT" == "true" ]]; then
        print_info "Checking remote config..."
        if validate_remote_config_shape; then
          print_success "Remote config shape is valid"
        else
          failed=1
        fi

        print_info "Checking remote connectivity..."
        if is_remote_host_reachable "$BACKUP_SERVER"; then
          print_success "Remote host is reachable: $BACKUP_SERVER"
        else
          print_warn "Remote host is unreachable: $BACKUP_SERVER"
          failed=1
        fi

        if [[ "$failed" -eq 0 ]]; then
          print_info "Checking remote backup path..."
          if require_remote_directory_ready "$BACKUP_SERVER" "$BACKUP_PATH" "Remote backup path"; then
            print_success "Remote backup path is ready"
          else
            failed=1
          fi

          print_info "Checking remote repo path..."
          if require_remote_server_repo_ready "$BACKUP_SERVER"; then
            print_success "Remote repo path is ready"
          else
            failed=1
          fi
        fi
      else
        print_warn "Private remote config not present; backup/server commands are unavailable"
      fi

      df -h /nix/store

      if [[ "$failed" -ne 0 ]]; then
        exit 1
      fi
    }

    cmd_validate_fast() {
      print_info "Parsing tracked Nix files..."
      (
        cd "$PROJECT_DIR"
        git ls-files '*.nix' | while IFS= read -r file; do
          nix-instantiate --parse "$file" >/dev/null
        done
      )

      if [[ "$PRIVATE_CONFIG_PRESENT" == "true" ]]; then
        print_info "Validating remote config shape..."
        validate_remote_config_shape
      fi

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
      ensure_sudo_session
      print_info "Trimming mounted filesystems..."
      run_sudo "$fstrim_bin" -av
      print_success "Trim complete"
    }

    cmd_backup() {
      validate_remote_config_shape
      require_remote_host "$BACKUP_SERVER"
      require_remote_directory_ready "$BACKUP_SERVER" "$BACKUP_PATH" "Remote backup path"

      print_info "Backing up dotfiles to $BACKUP_SERVER:$BACKUP_PATH..."
      rsync -avz --delete --chmod=Du+w,Fu+w "$PROJECT_DIR/" "$BACKUP_SERVER:$BACKUP_PATH/"
      print_success "Backup complete -> $BACKUP_SERVER:$BACKUP_PATH"
    }

    cmd_server() {
      local subcmd="''${1:-}"
      local server_host="$BACKUP_SERVER"
      local server_repo="$SERVER_REPO_PATH"

      case "$subcmd" in
        rebuild)
          validate_remote_config_shape
          require_remote_host "$server_host"
          require_remote_server_repo_ready "$server_host"

          print_info "Pulling and rebuilding on $server_host..."
          # shellcheck disable=SC2029
          ssh -t "$server_host" "cd \"$server_repo\" && dot rebuild"
          print_success "Server rebuild complete"
          ;;
        update)
          validate_remote_config_shape
          require_remote_host "$server_host"
          require_remote_server_repo_ready "$server_host"

          print_info "Syncing to $server_host:$server_repo..."
          rsync -avz --delete --chmod=Du+w,Fu+w "$PROJECT_DIR/" "$server_host:$server_repo/"

          print_info "Updating flake and rebuilding on $server_host..."
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
