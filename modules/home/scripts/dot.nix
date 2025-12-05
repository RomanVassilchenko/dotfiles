{
  pkgs,
  profile,
  backupFiles ? [ ".config/mimeapps.list.backup" ],
  ...
}:
let
  backupFilesString = pkgs.lib.strings.concatStringsSep " " backupFiles;
in

pkgs.writeShellScriptBin "dot" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  # --- Program info ---
  #
  # dot - NixOS System Management CLI
  # ==================================
  #
  #    Purpose: NixOS system management utility for Dotfiles distribution
  #     Author: Don Williams (ddubs) & Zaney
  # Start Date: June 7th, 2025
  #    Version: 1.0.2
  #
  # Architecture:
  # - Nix-generated shell script using writeShellScriptBin
  # - Configuration via Nix parameters (profile, backupFiles)
  # - Uses 'nh' tool for NixOS operations, 'inxi' for diagnostics
  # - Git integration for host configuration versioning
  #
  # Helper Functions:
  # verify_hostname()     - Validates that host configuration exists for current hostname
  #                        Exits with error if missing host directory
  # detect_gpu_profile()  - Parses lspci output to identify GPU hardware
  #                        Returns: nvidia/nvidia-laptop/amd-hybrid/amd/intel/vm/empty
  # handle_backups()      - Removes files listed in BACKUP_FILES array from $HOME
  # parse_nh_args()      - Parses command-line arguments for nh operations
  # print_help()         - Outputs command usage and available operations
  #
  # Command Functions:
  # cleanup              - Interactive cleanup of old generations via 'nh clean'
  # diag                 - Generate system report using 'inxi --full'
  # list-gens           - Display user/system generations via nix-env and nix profile
  # rebuild             - NixOS rebuild for current hostname using 'nh os switch'
  # rebuild-boot        - NixOS rebuild for next boot using 'nh os boot'
  # trim                - SSD optimization via 'sudo fstrim -v /'
  # update              - Flake update + rebuild for current hostname using 'nh os switch --update'
  # add-host            - Add new host configuration
  # del-host            - Delete host configuration
  # stow                - Run GNU Stow with override flag; auto-stows all packages if no args
  #
  # Variables:
  # PROJECT             - Base directory name (ddubsos/dotfiles)
  # PROFILE             - Hardware profile from Nix parameter
  # BACKUP_FILES        - Array of backup file paths to clean
  # FLAKE_NIX_PATH      - Path to flake.nix
  #


  # --- Configuration ---
  PROJECT="dotfiles"   #ddubos or dotfiles
  PROFILE="${profile}"
  BACKUP_FILES_STR="${backupFilesString}"
  VERSION="1.1.0"
  FLAKE_NIX_PATH="$HOME/$PROJECT/flake.nix"

  read -r -a BACKUP_FILES <<< "$BACKUP_FILES_STR"

  # --- Helper Functions ---
  verify_hostname() {
    local current_hostname
    current_hostname="$(hostname)"

    # Check if host folder exists for current hostname
    local folder="$HOME/$PROJECT/hosts/$current_hostname"
    if [ ! -d "$folder" ]; then
      echo "Error: No configuration found for host '$current_hostname'" >&2
      echo "  Missing folder: $folder" >&2
      echo "" >&2
      echo "Hint: Run 'dot add-host $current_hostname' to create configuration" >&2
      echo "      or run 'dot-setup' for guided setup" >&2
      exit 1
    fi

    # Verify the nixosConfiguration exists in flake.nix
    if [ -f "$FLAKE_NIX_PATH" ]; then
      if ! ${pkgs.gnugrep}/bin/grep -q "^[[:space:]]*$current_hostname[[:space:]]*=" "$FLAKE_NIX_PATH"; then
        echo "Warning: Configuration for '$current_hostname' not found in flake.nix outputs" >&2
        echo "  Host folder exists, but nixosConfiguration may be missing" >&2
        echo "  Attempting to rebuild anyway (will use host-specific configuration)..." >&2
      fi
    fi
  }

  print_help() {
    echo "Dotfiles CLI Utility -- version $VERSION"
    echo ""
    echo "Usage: dot [command] [options]"
    echo ""
    echo "Commands:"
    echo "  cleanup [all]   - Clean up old system generations. Use 'all' to remove all but current."
    echo "                    (Usage: dot cleanup or dot cleanup all)"
    echo "  diag            - Create a system diagnostic report."
    echo "                    (Filename: homedir/diag.txt)"
    echo "  list-gens       - List user and system generations."
    echo "  rebuild         - Rebuild the NixOS system for current hostname."
    echo "  rebuild-boot    - Rebuild and set as boot default (activates on next restart)."
    echo "  trim            - Trim filesystems to improve SSD performance."
    echo "  update          - Update the flake and rebuild the system for current hostname."
    echo "  add-host        - Add new host configuration."
    echo "                    (Usage: dot add-host [hostname] [profile])"
    echo "  del-host        - Delete host configuration."
    echo "                    (Usage: dot del-host [hostname])"
    echo "  stow            - Run GNU Stow with override to manage symlinks."
    echo "                    (Usage: dot stow [packages...] or dot stow to stow all)"
    echo "  doctor          - Run system health checks and diagnostics."
    echo ""
    echo "Options for rebuild, rebuild-boot, and update commands:"
    echo "  --dry, -n       - Show what would be done without doing it"
    echo "  --ask, -a       - Ask for confirmation before proceeding"
    echo "  --cores N       - Limit build to N cores (useful for VMs)"
    echo "  --verbose, -v   - Show verbose output"
    echo "  --no-nom        - Don't use nix-output-monitor"
    echo ""
    echo "  help            - Show this help message."
  }

  handle_backups() {
    if [ ''${#BACKUP_FILES[@]} -eq 0 ]; then
      echo "No backup files configured to check."
      return
    fi

    echo "Checking for backup files to remove..."
    for file_path in "''${BACKUP_FILES[@]}"; do
      full_path="$HOME/$file_path"
      if [ -f "$full_path" ]; then
        echo "Removing stale backup file: $full_path"
        rm "$full_path"
      fi
    done
  }

  detect_gpu_profile() {
    local detected_profile=""
    local has_nvidia=false
    local has_intel=false
    local has_amd=false
    local has_vm=false

    if ${pkgs.pciutils}/bin/lspci &> /dev/null; then # Check if lspci is available
      if ${pkgs.pciutils}/bin/lspci | ${pkgs.gnugrep}/bin/grep -qi 'vga\|3d'; then
        while read -r line; do
          if echo "$line" | ${pkgs.gnugrep}/bin/grep -qi 'nvidia'; then
            has_nvidia=true
          elif echo "$line" | ${pkgs.gnugrep}/bin/grep -qi 'amd'; then
            has_amd=true
          elif echo "$line" | ${pkgs.gnugrep}/bin/grep -qi 'intel'; then
            has_intel=true
          elif echo "$line" | ${pkgs.gnugrep}/bin/grep -qi 'virtio\|vmware'; then
            has_vm=true
          fi
        done < <(${pkgs.pciutils}/bin/lspci | ${pkgs.gnugrep}/bin/grep -i 'vga\|3d')

        if "$has_vm"; then
          detected_profile="vm"
        elif "$has_nvidia" && "$has_intel"; then
          detected_profile="nvidia-laptop"
        elif "$has_nvidia" && "$has_amd"; then
          detected_profile="amd-hybrid"
        elif "$has_nvidia"; then
          detected_profile="nvidia"
        elif "$has_amd"; then
          detected_profile="amd"
        elif "$has_intel"; then
          detected_profile="intel"
        fi
      fi
    else
      echo "Warning: lspci command not found. Cannot auto-detect GPU profile." >&2
    fi
    echo "$detected_profile" # Return the detected profile
  }

  # --- Helper function to parse additional arguments ---
  parse_nh_args() {
    local args_string=""
    local options_selected=()
    shift # Remove the main command (rebuild, rebuild-boot, update)

    while [[ $# -gt 0 ]]; do
      case $1 in
        --dry|-n)
          args_string="$args_string --dry"
          options_selected+=("dry run mode (showing what would be done)")
          shift
          ;;
        --ask|-a)
          args_string="$args_string --ask"
          options_selected+=("confirmation prompts enabled")
          shift
          ;;
        --cores)
          if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
            args_string="$args_string -- --cores $2"
            options_selected+=("limited to $2 CPU cores")
            shift 2
          else
            echo "Error: --cores requires a numeric argument" >&2
            exit 1
          fi
          ;;
        --verbose|-v)
          args_string="$args_string --verbose"
          options_selected+=("verbose output enabled")
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
          options_selected+=("additional arguments: $*")
          break
          ;;
        -*)
          echo "Warning: Unknown flag '$1' - passing through to nh" >&2
          args_string="$args_string $1"
          options_selected+=("unknown flag '$1' passed through")
          shift
          ;;
        *)
          echo "Error: Unexpected argument '$1'" >&2
          exit 1
          ;;
      esac
    done

    # Print friendly confirmation of selected options to stderr so it doesn't interfere with return value
    if [[ ''${#options_selected[@]} -gt 0 ]]; then
      echo "Options selected:" >&2
      for option in "''${options_selected[@]}"; do
        echo "  ✓ $option" >&2
      done
      echo >&2
    fi

    # Return only the args string
    echo "$args_string"
  }

  # --- Main Logic ---
  if [ "$#" -eq 0 ]; then
    echo "Error: No command provided." >&2
    print_help
    exit 1
  fi

  case "$1" in
    cleanup)
      # Check if 'all' argument is provided to skip prompts
      if [ "$#" -ge 2 ] && [ "$2" == "all" ]; then
        echo "Removing all generations except the current one..."
        echo "This will leave only one entry in the systemd boot menu."
        ${pkgs.nh}/bin/nh clean all --keep 1 -v
        echo "Cleanup complete. Only the current generation remains."
      else
        echo "Warning! This will remove old generations of your system."
        read -p "How many generations to keep (default: 1)? " keep_count

        # Default to keeping 1 generation if user just presses enter
        if [ -z "$keep_count" ]; then
          keep_count=1
        fi

        read -p "This will keep the last $keep_count generation(s). Continue (y/N)? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          ${pkgs.nh}/bin/nh clean all --keep "$keep_count" -v
          echo "Cleanup complete. Kept $keep_count generation(s)."
        else
          echo "Cleanup cancelled."
        fi
      fi

      LOG_DIR="/tmp/dot-cleanup-logs"
      mkdir -p "$LOG_DIR"
      LOG_FILE="$LOG_DIR/dot-cleanup-$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).log"
      echo "Cleaning up old log files..." >> "$LOG_FILE"
      ${pkgs.findutils}/bin/find "$LOG_DIR" -type f -mtime +3 -name "*.log" -delete >> "$LOG_FILE" 2>&1
      echo "Cleanup process logged to $LOG_FILE"
      ;;
    diag)
      echo "Generating system diagnostic report..."
      ${pkgs.inxi}/bin/inxi --full > "$HOME/diag.txt"
      echo "Diagnostic report saved to $HOME/diag.txt"
      ;;
    help)
      print_help
      ;;
    list-gens)
      echo "--- User Generations ---"
      ${pkgs.nix}/bin/nix-env --list-generations | ${pkgs.coreutils}/bin/cat || echo "Could not list user generations."
      echo ""
      echo "--- System Generations ---"
      ${pkgs.nix}/bin/nix profile history --profile /nix/var/nix/profiles/system | ${pkgs.coreutils}/bin/cat || echo "Could not list system generations."
      ;;
    rebuild)
      verify_hostname
      handle_backups

      # Parse additional arguments
      extra_args=$(parse_nh_args "$@")

      current_hostname=$(${pkgs.nettools}/bin/hostname)
      echo "Starting NixOS rebuild for host: $current_hostname"
      if eval "${pkgs.nh}/bin/nh os switch --hostname '$current_hostname' $extra_args"; then
        echo "Rebuild finished successfully"
      else
        echo "Rebuild Failed" >&2
        exit 1
      fi
      ;;
    rebuild-boot)
      verify_hostname
      handle_backups

      # Parse additional arguments
      extra_args=$(parse_nh_args "$@")

      current_hostname=$(${pkgs.nettools}/bin/hostname)
      echo "Starting NixOS rebuild (boot) for host: $current_hostname"
      echo "Note: Configuration will be activated on next reboot"
      if eval "${pkgs.nh}/bin/nh os boot --hostname '$current_hostname' $extra_args"; then
        echo "Rebuild-boot finished successfully"
        echo "New configuration set as boot default - restart to activate"
      else
        echo "Rebuild-boot Failed" >&2
        exit 1
      fi
      ;;
    trim)
      echo "Running 'sudo fstrim -v /' may take a few minutes and impact system performance."
      read -p "Enter (y/Y) to run now or enter to exit (y/N): " -n 1 -r
      echo # move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Running fstrim..."
        sudo ${pkgs.util-linux}/bin/fstrim -v /
        echo "fstrim complete."
      else
        echo "Trim operation cancelled."
      fi
      ;;
    update)
      verify_hostname
      handle_backups

      # Parse additional arguments
      extra_args=$(parse_nh_args "$@")

      current_hostname=$(${pkgs.nettools}/bin/hostname)
      echo "Updating flake and rebuilding system for host: $current_hostname"
      if eval "${pkgs.nh}/bin/nh os switch --hostname '$current_hostname' --update $extra_args"; then
        echo "Update and rebuild finished successfully"
      else
        echo "Update and rebuild Failed" >&2
        exit 1
      fi
      ;;
    add-host)
      hostname=""
      profile_arg=""

      if [ "$#" -ge 2 ]; then
        hostname="$2"
      fi
      if [ "$#" -eq 3 ]; then
        profile_arg="$3"
      fi

      if [ -z "$hostname" ]; then
        read -p "Enter the new hostname: " hostname
      fi

      if [ -d "$HOME/$PROJECT/hosts/$hostname" ]; then
        echo "Error: Host '$hostname' already exists." >&2
        exit 1
      fi

      echo "Copying default host configuration..."
      ${pkgs.coreutils}/bin/cp -r "$HOME/$PROJECT/hosts/default" "$HOME/$PROJECT/hosts/$hostname"

      detected_profile=""
      if [[ -n "$profile_arg" && "$profile_arg" =~ ^(intel|amd|nvidia|nvidia-laptop|amd-hybrid|vm)$ ]]; then
        detected_profile="$profile_arg"
      else
        echo "Detecting GPU profile..."
        detected_profile=$(detect_gpu_profile)
        echo "Detected GPU profile: $detected_profile"
        read -p "Is this correct? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
          read -p "Enter the correct profile (intel, amd, nvidia, nvidia-laptop, amd-hybrid, vm): " new_profile
          while [[ ! "$new_profile" =~ ^(intel|amd|nvidia|nvidia-laptop|amd-hybrid|vm)$ ]]; do
            echo "Invalid profile. Please enter one of the following: intel, amd, nvidia, nvidia-laptop, amd-hybrid, vm"
            read -p "Enter the correct profile: " new_profile
          done
          detected_profile=$new_profile
        fi
      fi

      echo "Setting profile to '$detected_profile'..."

      # Ask about system type (laptop/desktop or server)
      echo ""
      echo "What type of system is this?"
      echo "  1) laptop/desktop (GUI with KDE Plasma)"
      echo "  2) server (no GUI, CLI only)"
      echo ""
      read -p "Enter choice (1 or 2): " -n 1 -r
      echo

      SYSTEM_TYPE="laptop"
      if [[ $REPLY == "2" ]]; then
        SYSTEM_TYPE="server"
        echo "Selected: Server (no GUI)"
      else
        SYSTEM_TYPE="laptop"
        echo "Selected: Laptop/Desktop (with GUI)"
      fi

      # Update deviceType in variables.nix based on user selection
      ${pkgs.gnused}/bin/sed -i "s/deviceType = \"laptop\";/deviceType = \"$SYSTEM_TYPE\";/" "$HOME/$PROJECT/hosts/$hostname/variables.nix"
      echo "Set deviceType to '$SYSTEM_TYPE'"

      echo ""
      read -p "Generate new hardware.nix? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Generating hardware.nix..."
        sudo nixos-generate-config --show-hardware-config > "$HOME/$PROJECT/hosts/$hostname/hardware.nix"
        echo "hardware.nix generated."
      fi

      echo "Adding new host to git..."
      ${pkgs.git}/bin/git -C "$HOME/$PROJECT" add .
      echo "hostname: $hostname added"
      ;;
    del-host)
      hostname=""
      if [ "$#" -eq 2 ]; then
        hostname="$2"
      else
        read -p "Enter the hostname to delete: " hostname
      fi

      if [ ! -d "$HOME/$PROJECT/hosts/$hostname" ]; then
        echo "Error: Host '$hostname' does not exist." >&2
        exit 1
      fi

      read -p "Are you sure you want to delete the host '$hostname'? (y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting host '$hostname'..."
        ${pkgs.coreutils}/bin/rm -rf "$HOME/$PROJECT/hosts/$hostname"
        ${pkgs.git}/bin/git -C "$HOME/$PROJECT" add .
        echo "hostname: $hostname removed"
      else
        echo "Deletion cancelled."
      fi
      ;;
    stow)
      shift # Remove 'stow' from arguments

      # If no arguments provided, stow all directories in stow/
      if [ "$#" -eq 0 ]; then
        echo "No packages specified - stowing all packages in $HOME/$PROJECT/stow"
        cd "$HOME/$PROJECT" || exit 1

        # Find all directories in stow/ subdirectory
        packages=()
        if [ -d "stow" ]; then
          for dir in stow/*/; do
            if [ -d "$dir" ]; then
              dir_name=$(basename "$dir")
              packages+=("$dir_name")
            fi
          done
        fi

        if [ ''${#packages[@]} -eq 0 ]; then
          echo "No stow packages found in $HOME/$PROJECT/stow"
          exit 0
        fi

        echo "Found packages: ''${packages[*]}"
        echo "Running: stow --override=.* ''${packages[*]}"
        ${pkgs.stow}/bin/stow --override=.* "''${packages[@]}"
      else
        echo "Running stow with override: stow --override=.* $*"
        ${pkgs.stow}/bin/stow --override=.* "$@"
      fi
      ;;
    doctor)
      echo "Running system health checks..."
      echo ""

      # Colors
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[0;33m'
      BLUE='\033[0;34m'
      NC='\033[0m' # No Color

      checks_passed=0
      checks_failed=0
      checks_warned=0

      check_pass() {
        echo -e "''${GREEN}[PASS]''${NC} $1"
        ((checks_passed++))
      }

      check_fail() {
        echo -e "''${RED}[FAIL]''${NC} $1"
        ((checks_failed++))
      }

      check_warn() {
        echo -e "''${YELLOW}[WARN]''${NC} $1"
        ((checks_warned++))
      }

      check_info() {
        echo -e "''${BLUE}[INFO]''${NC} $1"
      }

      # --- System Checks ---
      echo -e "''${BLUE}=== System Checks ===''${NC}"

      # Check NixOS version
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        check_info "NixOS Version: $VERSION"
      fi

      # Check kernel version
      check_info "Kernel: $(uname -r)"

      # Check hostname configuration
      current_hostname=$(hostname)
      if [ -d "$HOME/$PROJECT/hosts/$current_hostname" ]; then
        check_pass "Host configuration exists for '$current_hostname'"
      else
        check_fail "Host configuration missing for '$current_hostname'"
      fi

      echo ""
      echo -e "''${BLUE}=== Service Checks ===''${NC}"

      # Check failed services
      failed_system=$(systemctl --system --failed --no-legend 2>/dev/null | wc -l)
      failed_user=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)

      if [ "$failed_system" -eq 0 ]; then
        check_pass "No failed system services"
      else
        check_fail "$failed_system failed system service(s)"
        systemctl --system --failed --no-legend 2>/dev/null | while read -r line; do
          echo "       - $line"
        done
      fi

      if [ "$failed_user" -eq 0 ]; then
        check_pass "No failed user services"
      else
        check_fail "$failed_user failed user service(s)"
        systemctl --user --failed --no-legend 2>/dev/null | while read -r line; do
          echo "       - $line"
        done
      fi

      echo ""
      echo -e "''${BLUE}=== Disk Checks ===''${NC}"

      # Check disk space
      root_usage=$(df / --output=pcent | tail -1 | tr -d ' %')
      if [ "$root_usage" -lt 80 ]; then
        check_pass "Root filesystem usage: $root_usage%"
      elif [ "$root_usage" -lt 90 ]; then
        check_warn "Root filesystem usage: $root_usage% (consider cleanup)"
      else
        check_fail "Root filesystem usage: $root_usage% (critically low!)"
      fi

      # Check /nix/store size
      nix_store_size=$(du -sh /nix/store 2>/dev/null | cut -f1 || echo "unknown")
      check_info "Nix store size: $nix_store_size"

      # Count generations
      gen_count=$(${pkgs.nix}/bin/nix profile history --profile /nix/var/nix/profiles/system 2>/dev/null | grep -c "Version" || echo "0")
      if [ "$gen_count" -gt 10 ]; then
        check_warn "System has $gen_count generations (consider 'dot cleanup')"
      else
        check_pass "System generations: $gen_count"
      fi

      echo ""
      echo -e "''${BLUE}=== Network Checks ===''${NC}"

      # Check internet connectivity
      if ${pkgs.curl}/bin/curl -s --max-time 5 https://nixos.org > /dev/null 2>&1; then
        check_pass "Internet connectivity OK"
      else
        check_warn "Cannot reach nixos.org (may be offline)"
      fi

      # Check if firewall is enabled
      if systemctl is-active --quiet firewall 2>/dev/null || systemctl is-active --quiet iptables 2>/dev/null; then
        check_pass "Firewall is active"
      else
        check_info "Firewall status unknown"
      fi

      echo ""
      echo -e "''${BLUE}=== Security Checks ===''${NC}"

      # Check fail2ban
      if systemctl is-active --quiet fail2ban 2>/dev/null; then
        check_pass "Fail2ban is running"
      else
        check_warn "Fail2ban is not running"
      fi

      # Check SSH
      if systemctl is-active --quiet sshd 2>/dev/null; then
        check_pass "SSH daemon is running"
      fi

      echo ""
      echo -e "''${BLUE}=== Git Repository Checks ===''${NC}"

      # Check for uncommitted changes
      cd "$HOME/$PROJECT" || exit 1
      if ${pkgs.git}/bin/git diff --quiet 2>/dev/null; then
        check_pass "No uncommitted changes in dotfiles"
      else
        check_warn "Uncommitted changes in dotfiles"
      fi

      # Check if ahead/behind remote
      ${pkgs.git}/bin/git fetch origin --quiet 2>/dev/null || true
      local_hash=$(${pkgs.git}/bin/git rev-parse HEAD 2>/dev/null)
      remote_hash=$(${pkgs.git}/bin/git rev-parse origin/main 2>/dev/null || echo "")

      if [ -n "$remote_hash" ]; then
        if [ "$local_hash" = "$remote_hash" ]; then
          check_pass "Dotfiles up to date with remote"
        else
          ahead=$(${pkgs.git}/bin/git rev-list origin/main..HEAD --count 2>/dev/null || echo "0")
          behind=$(${pkgs.git}/bin/git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
          if [ "$ahead" -gt 0 ]; then
            check_info "Dotfiles $ahead commit(s) ahead of remote"
          fi
          if [ "$behind" -gt 0 ]; then
            check_warn "Dotfiles $behind commit(s) behind remote"
          fi
        fi
      fi

      echo ""
      echo "========================================"
      echo -e "Results: ''${GREEN}$checks_passed passed''${NC}, ''${YELLOW}$checks_warned warnings''${NC}, ''${RED}$checks_failed failed''${NC}"

      if [ "$checks_failed" -gt 0 ]; then
        exit 1
      fi
      ;;
    *)
      echo "Error: Invalid command '$1'" >&2
      print_help
      exit 1
      ;;
  esac
''
