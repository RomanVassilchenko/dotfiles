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
  VERSION="1.0.2"
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

      # Update systemType in variables.nix based on user selection
      ${pkgs.gnused}/bin/sed -i "s/systemType = \"laptop\";/systemType = \"$SYSTEM_TYPE\";/" "$HOME/$PROJECT/hosts/$hostname/variables.nix"
      echo "Set systemType to '$SYSTEM_TYPE'"

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
    *)
      echo "Error: Invalid command '$1'" >&2
      print_help
      exit 1
      ;;
  esac
''
