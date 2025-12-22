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
#   setup              - Run guided setup wizard for new machines
#   format [type]      - Format files (nix, md, sh, or all)
#   rebuild [opts]     - Rebuild NixOS system
#   rebuild-boot       - Rebuild for next boot
#   update [opts]      - Update flake and rebuild
#   backup             - Backup dotfiles to ninkear
#   cleanup [all]      - Clean old generations
#   doctor             - Run system health checks
#   diag               - Generate diagnostic report
#   list-gens          - List generations
#   trim               - Run fstrim for SSD
#   add-host           - Add new host configuration
#   del-host           - Delete host configuration
#   stow [packages]    - Run GNU Stow
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
BACKUP_SERVER="100.64.0.1"
BACKUP_PATH="/home/romanv/backup/dotfiles"

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

# Check if ninkear is reachable via SSH
is_ninkear_reachable() {
  ssh -o ConnectTimeout=3 -o BatchMode=yes "$BACKUP_SERVER" "exit" 2>/dev/null
}

# Ensure Tailscale connection to ninkear for binary cache
ensure_ninkear_connected() {
  print_info "Checking ninkear P2P connection for binary cache..."

  if ! tailscale status --json 2>/dev/null | jq -e '.BackendState == "Running"' >/dev/null 2>&1; then
    print_info "Tailscale not connected. Connecting to ninkear P2P..."

    # Start cloudflared tunnel only if not already running
    if ! ss -tlnp 2>/dev/null | grep -q ':18085'; then
      cloudflared access tcp \
        --hostname headscale.romanv.dev \
        --url 127.0.0.1:18085 &
      CLOUDFLARED_PID=$!
      sleep 2
    fi

    if sudo tailscale up --login-server http://127.0.0.1:18085 --accept-routes --accept-dns=false; then
      print_success "Connected to ninkear P2P"
    else
      print_warn "Failed to connect to ninkear P2P - build may be slower without binary cache"
      [[ -n "${CLOUDFLARED_PID:-}" ]] && kill $CLOUDFLARED_PID 2>/dev/null || true
    fi
  else
    print_success "Ninkear P2P already connected"
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
  print_info "Checking for backup files to remove..."

  # Clean up .hm-bak files
  find "$HOME/.config" "$HOME" -maxdepth 3 -name "*.hm-bak" -type f 2>/dev/null | while read -r file; do
    echo "Removing stale backup: $file"
    rm -f "$file"
  done

  # Clean up configured backup files
  for file_path in "${BACKUP_FILES[@]}"; do
    full_path="$HOME/$file_path"
    if [[ -f "$full_path" ]]; then
      echo "Removing stale backup file: $full_path"
      rm -f "$full_path"
    fi
  done
}

# Auto-detect GPU profile
detect_gpu_profile() {
  local detected_profile=""
  local has_nvidia=false
  local has_intel=false
  local has_amd=false
  local has_vm=false

  if check_command lspci; then
    if lspci | grep -qi 'vga\|3d'; then
      while read -r line; do
        if echo "$line" | grep -qi 'nvidia'; then
          has_nvidia=true
        elif echo "$line" | grep -qi 'amd'; then
          has_amd=true
        elif echo "$line" | grep -qi 'intel'; then
          has_intel=true
        elif echo "$line" | grep -qi 'virtio\|vmware'; then
          has_vm=true
        fi
      done < <(lspci | grep -i 'vga\|3d')

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
    print_warn "lspci not found. Cannot auto-detect GPU profile."
  fi
  echo "$detected_profile"
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
      --no-backup)
        NO_BACKUP=true
        options_selected+=("backup disabled")
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

# Backup to ninkear (silent fail if unreachable)
do_backup() {
  if [[ "${NO_BACKUP:-false}" == "true" ]]; then
    return 0
  fi

  print_info "Backing up dotfiles to ninkear..."

  if ! is_ninkear_reachable; then
    print_warn "Ninkear not reachable, skipping backup"
    return 0
  fi

  # Create backup directory if needed
  ssh "$BACKUP_SERVER" "mkdir -p $BACKUP_PATH"

  # Sync dotfiles
  rsync -avz --delete --chmod=Du+w,Fu+w \
    "$PROJECT_DIR/" \
    "$BACKUP_SERVER:$BACKUP_PATH/"

  print_success "Backup completed to $BACKUP_SERVER:$BACKUP_PATH"
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
  echo -e "${BOLD}SYSTEM COMMANDS${NC}"
  echo -e "    ${CYAN}rebuild${NC} [opts]     Rebuild NixOS system (auto-backup on success)"
  echo -e "    ${CYAN}rebuild-boot${NC}       Rebuild for next boot"
  echo -e "    ${CYAN}update${NC} [opts]      Update flake inputs and rebuild"
  echo -e "    ${CYAN}cleanup${NC} [all]      Clean old generations"
  echo -e "    ${CYAN}trim${NC}               Run fstrim for SSD optimization"
  echo ""
  echo -e "${BOLD}DEVELOPMENT${NC}"
  echo -e "    ${CYAN}format${NC} [type]      Format files (nix, md, sh, or all)"
  echo -e "    ${CYAN}stow${NC} [packages]    Manage symlinks with GNU Stow"
  echo ""
  echo -e "${BOLD}CONFIGURATION${NC}"
  echo -e "    ${CYAN}setup${NC}              Guided wizard for new machines"
  echo -e "    ${CYAN}add-host${NC} [name]    Add new host configuration"
  echo -e "    ${CYAN}del-host${NC} [name]    Delete host configuration"
  echo ""
  echo -e "${BOLD}DIAGNOSTICS${NC}"
  echo -e "    ${CYAN}doctor${NC}             Run system health checks"
  echo -e "    ${CYAN}diag${NC}               Generate diagnostic report"
  echo -e "    ${CYAN}list-gens${NC}          List system generations"
  echo -e "    ${CYAN}backup${NC}             Backup dotfiles to ninkear"
  echo ""
  echo -e "${BOLD}OPTIONS (rebuild/update)${NC}"
  echo "    --dry, -n          Show what would be done"
  echo "    --ask, -a          Ask for confirmation"
  echo "    --cores N          Limit to N CPU cores"
  echo "    --verbose, -v      Verbose output"
  echo "    --no-nom           Disable nix-output-monitor"
  echo "    --no-backup        Skip auto-backup after success"
  echo ""
  echo -e "${BOLD}EXAMPLES${NC}"
  echo "    dot rebuild              # Rebuild system"
  echo "    dot rebuild --dry        # Preview changes"
  echo "    dot format               # Format all files"
  echo "    dot format nix           # Format only Nix files"
  echo "    dot setup                # New machine setup"
  echo ""
}

cmd_setup() {
  print_header "Dotfiles Setup Wizard"
  echo ""

  local current_hostname
  current_hostname=$(hostname)

  echo "Current hostname: $current_hostname"
  echo "Dotfiles directory: $PROJECT_DIR"
  echo ""

  # Check if configuration exists
  if [[ -d "$PROJECT_DIR/hosts/$current_hostname" ]]; then
    print_success "Configuration found for '$current_hostname'"
    echo ""

    if grep -q "^[[:space:]]*$current_hostname[[:space:]]*=" "$FLAKE_NIX_PATH"; then
      print_success "NixOS configuration found in flake.nix"
      echo ""
      echo "This device is already set up. You can run:"
      echo "  dot rebuild"
      echo ""
      read -rp "Would you like to rebuild now? (y/N) " -n 1
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        cmd_rebuild
      fi
    else
      print_warn "Host folder exists but no nixosConfiguration in flake.nix"
      echo ""
      echo "Please add the following to flake.nix nixosConfigurations:"
      echo ""
      echo "  $current_hostname = mkNixosConfig {"
      echo "    gpuProfile = \"<profile>\";"
      echo "    host = \"$current_hostname\";"
      echo "  };"
    fi
    return 0
  fi

  echo "No configuration found for '$current_hostname'"
  echo ""
  echo "Let's set up this device!"
  echo ""

  # Detect GPU
  print_info "Detecting GPU profile..."
  local detected_profile
  detected_profile=$(detect_gpu_profile)

  if [[ -n "$detected_profile" ]]; then
    echo "Detected GPU profile: $detected_profile"
  else
    detected_profile="intel"
    echo "Could not auto-detect GPU. Using default: $detected_profile"
  fi
  echo ""

  read -rp "Is '$detected_profile' correct? (Y/n) " -n 1
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Available profiles: intel, amd, nvidia, nvidia-laptop, amd-hybrid, vm"
    read -rp "Enter the correct profile: " detected_profile
  fi

  echo ""

  # System type
  echo "What type of system is this?"
  echo "  1) laptop/desktop (GUI with KDE Plasma)"
  echo "  2) server (no GUI, CLI only)"
  echo ""
  read -rp "Enter choice (1 or 2): " -n 1
  echo

  local system_type="laptop"
  if [[ $REPLY == "2" ]]; then
    system_type="server"
    print_info "Selected: Server (no GUI)"
  else
    print_info "Selected: Laptop/Desktop (with GUI)"
  fi

  echo ""
  print_info "Creating host configuration..."

  # Copy default config
  if [[ ! -d "$PROJECT_DIR/hosts/default" ]]; then
    print_error "Default host template not found at $PROJECT_DIR/hosts/default"
    exit 1
  fi

  cp -r "$PROJECT_DIR/hosts/default" "$PROJECT_DIR/hosts/$current_hostname"
  print_success "Copied default configuration"

  # Update deviceType
  sed -i "s/deviceType = \"laptop\";/deviceType = \"$system_type\";/" \
    "$PROJECT_DIR/hosts/$current_hostname/variables.nix"
  print_success "Set deviceType to '$system_type'"

  # Hardware config
  echo ""
  if [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
    echo "Found existing hardware configuration at /etc/nixos/hardware-configuration.nix"
    read -rp "Use existing hardware configuration? (Y/n) " -n 1
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      cp /etc/nixos/hardware-configuration.nix "$PROJECT_DIR/hosts/$current_hostname/hardware.nix"
      print_success "Copied hardware.nix from /etc/nixos"
    else
      print_info "Generating new hardware.nix..."
      sudo nixos-generate-config --show-hardware-config >"$PROJECT_DIR/hosts/$current_hostname/hardware.nix"
      print_success "Generated new hardware.nix"
    fi
  else
    print_info "Generating hardware.nix..."
    sudo nixos-generate-config --show-hardware-config >"$PROJECT_DIR/hosts/$current_hostname/hardware.nix"
    print_success "Generated hardware.nix"
  fi

  # Add to flake.nix
  print_info "Adding configuration to flake.nix..."

  local new_entry="        $current_hostname = mkNixosConfig {
          gpuProfile = \"$detected_profile\";
          host = \"$current_hostname\";
        };"

  if grep -q "^[[:space:]]*};[[:space:]]*$" "$FLAKE_NIX_PATH"; then
    sed -i "/^[[:space:]]*};[[:space:]]*$/i\\$new_entry" "$FLAKE_NIX_PATH"
    print_success "Added to flake.nix"
  else
    print_warn "Could not automatically add to flake.nix"
    echo "Please manually add:"
    echo "$new_entry"
  fi

  # Git hooks
  echo ""
  print_info "Setting up git hooks..."
  if [[ -f "$PROJECT_DIR/.github/git-hooks/prepare-commit-msg" ]]; then
    ln -sf ../../.github/git-hooks/prepare-commit-msg "$PROJECT_DIR/.git/hooks/prepare-commit-msg"
    print_success "Git hooks installed"
  fi

  # Create symlink
  echo ""
  read -rp "Create symlink to /usr/local/bin/dot? (Y/n) " -n 1
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo ln -sf "$PROJECT_DIR/dot.sh" /usr/local/bin/dot
    print_success "Symlink created: /usr/local/bin/dot -> $PROJECT_DIR/dot.sh"
  fi

  # Add to git
  git -C "$PROJECT_DIR" add .
  print_success "Added new host to git"

  echo ""
  print_header "Setup Complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Review: $PROJECT_DIR/hosts/$current_hostname/variables.nix"
  echo "  2. Run: dot rebuild"
  echo ""
}

cmd_format() {
  local format_type="${1:-all}"

  case "$format_type" in
    nix)
      print_info "Formatting Nix files..."
      find "$PROJECT_DIR" -name "*.nix" -not -path "*/.*" -print0 | xargs -0 nixfmt
      print_success "Nix files formatted"
      ;;
    md)
      print_info "Formatting Markdown files..."
      find "$PROJECT_DIR" -name "*.md" -not -path "*/.*" -print0 | xargs -0 prettier --write --prose-wrap always
      print_success "Markdown files formatted"
      ;;
    sh)
      print_info "Formatting shell scripts..."
      find "$PROJECT_DIR" -name "*.sh" -not -path "*/.*" -print0 | xargs -0 shfmt -w -i 2 -ci
      print_success "Shell scripts formatted"
      ;;
    all)
      cmd_format nix
      cmd_format md
      cmd_format sh
      ;;
    *)
      print_error "Unknown format type: $format_type"
      echo "Usage: dot format [nix|md|sh|all]"
      exit 1
      ;;
  esac
}

cmd_rebuild() {
  verify_hostname
  handle_backups
  ensure_ninkear_connected

  local extra_args
  extra_args=$(parse_nh_args "$@")

  local current_hostname
  current_hostname=$(hostname)

  print_info "Starting NixOS rebuild for host: $current_hostname"

  local nix_jobs="${NIX_BUILD_CORES:-auto}"

  if eval "nh os switch --hostname '$current_hostname' $extra_args -- --max-jobs $nix_jobs"; then
    print_success "Rebuild finished successfully"
    do_backup
  else
    print_error "Rebuild failed"
    exit 1
  fi
}

cmd_rebuild_boot() {
  verify_hostname
  handle_backups
  ensure_ninkear_connected

  local extra_args
  extra_args=$(parse_nh_args "$@")

  local current_hostname
  current_hostname=$(hostname)

  print_info "Starting NixOS rebuild (boot) for host: $current_hostname"
  print_info "Configuration will be activated on next reboot"

  local nix_jobs="${NIX_BUILD_CORES:-auto}"

  if eval "nh os boot --hostname '$current_hostname' $extra_args -- --max-jobs $nix_jobs"; then
    print_success "Rebuild-boot finished successfully"
    print_info "New configuration set as boot default - restart to activate"
    do_backup
  else
    print_error "Rebuild-boot failed"
    exit 1
  fi
}

cmd_update() {
  verify_hostname
  handle_backups
  ensure_ninkear_connected

  local extra_args
  extra_args=$(parse_nh_args "$@")

  local current_hostname
  current_hostname=$(hostname)

  print_info "Updating flake and rebuilding system for host: $current_hostname"

  local nix_jobs="${NIX_BUILD_CORES:-auto}"

  if eval "nh os switch --hostname '$current_hostname' --update $extra_args -- --max-jobs $nix_jobs"; then
    print_success "Update and rebuild finished successfully"

    # Update flatpak if available
    if check_command flatpak; then
      echo ""
      print_info "Updating Flatpak packages..."
      flatpak update -y
      print_success "Flatpak update complete"
    fi

    do_backup
  else
    print_error "Update and rebuild failed"
    exit 1
  fi
}

cmd_backup() {
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

cmd_cleanup() {
  if [[ "${1:-}" == "all" ]]; then
    print_info "Removing all generations except the current one..."
    nh clean all --keep 1 -v
    print_success "Cleanup complete. Only the current generation remains."
  else
    print_warn "This will remove old generations of your system."
    read -rp "How many generations to keep (default: 1)? " keep_count

    keep_count="${keep_count:-1}"

    read -rp "This will keep the last $keep_count generation(s). Continue (y/N)? " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      nh clean all --keep "$keep_count" -v
      print_success "Cleanup complete. Kept $keep_count generation(s)."
    else
      echo "Cleanup cancelled."
    fi
  fi

  # Clean old logs
  local log_dir="/tmp/dot-cleanup-logs"
  mkdir -p "$log_dir"
  find "$log_dir" -type f -mtime +3 -name "*.log" -delete 2>/dev/null || true
}

cmd_diag() {
  print_info "Generating system diagnostic report..."
  inxi --full >"$HOME/diag.txt"
  print_success "Diagnostic report saved to $HOME/diag.txt"
}

cmd_list_gens() {
  echo "--- User Generations ---"
  nix-env --list-generations || echo "Could not list user generations."
  echo ""
  echo "--- System Generations ---"
  nix profile history --profile /nix/var/nix/profiles/system || echo "Could not list system generations."
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

cmd_add_host() {
  local hostname="${1:-}"
  local profile_arg="${2:-}"

  if [[ -z "$hostname" ]]; then
    read -rp "Enter the new hostname: " hostname
  fi

  if [[ -d "$PROJECT_DIR/hosts/$hostname" ]]; then
    print_error "Host '$hostname' already exists."
    exit 1
  fi

  print_info "Copying default host configuration..."
  cp -r "$PROJECT_DIR/hosts/default" "$PROJECT_DIR/hosts/$hostname"

  local detected_profile=""
  if [[ -n "$profile_arg" && "$profile_arg" =~ ^(intel|amd|nvidia|nvidia-laptop|amd-hybrid|vm)$ ]]; then
    detected_profile="$profile_arg"
  else
    print_info "Detecting GPU profile..."
    detected_profile=$(detect_gpu_profile)
    echo "Detected GPU profile: $detected_profile"
    read -rp "Is this correct? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      read -rp "Enter the correct profile (intel, amd, nvidia, nvidia-laptop, amd-hybrid, vm): " detected_profile
    fi
  fi

  print_info "Setting profile to '$detected_profile'..."

  # System type
  echo ""
  echo "What type of system is this?"
  echo "  1) laptop/desktop (GUI with KDE Plasma)"
  echo "  2) server (no GUI, CLI only)"
  echo ""
  read -rp "Enter choice (1 or 2): " -n 1
  echo

  local system_type="laptop"
  if [[ $REPLY == "2" ]]; then
    system_type="server"
    print_info "Selected: Server (no GUI)"
  else
    print_info "Selected: Laptop/Desktop (with GUI)"
  fi

  sed -i "s/deviceType = \"laptop\";/deviceType = \"$system_type\";/" \
    "$PROJECT_DIR/hosts/$hostname/variables.nix"
  print_success "Set deviceType to '$system_type'"

  echo ""
  read -rp "Generate new hardware.nix? (y/n) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Generating hardware.nix..."
    sudo nixos-generate-config --show-hardware-config >"$PROJECT_DIR/hosts/$hostname/hardware.nix"
    print_success "hardware.nix generated."
  fi

  print_info "Adding new host to git..."
  git -C "$PROJECT_DIR" add .
  print_success "hostname: $hostname added"
}

cmd_del_host() {
  local hostname="${1:-}"

  if [[ -z "$hostname" ]]; then
    read -rp "Enter the hostname to delete: " hostname
  fi

  if [[ ! -d "$PROJECT_DIR/hosts/$hostname" ]]; then
    print_error "Host '$hostname' does not exist."
    exit 1
  fi

  read -rp "Are you sure you want to delete the host '$hostname'? (y/N) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Deleting host '$hostname'..."
    rm -rf "${PROJECT_DIR:?}/hosts/$hostname"
    git -C "$PROJECT_DIR" add .
    print_success "hostname: $hostname removed"
  else
    echo "Deletion cancelled."
  fi
}

cmd_stow() {
  shift || true # Remove 'stow' from arguments

  if [[ $# -eq 0 ]]; then
    print_info "No packages specified - stowing all packages in $PROJECT_DIR/stow"
    cd "$PROJECT_DIR" || exit 1

    local packages=()
    if [[ -d "stow" ]]; then
      for dir in stow/*/; do
        if [[ -d "$dir" ]]; then
          packages+=("$(basename "$dir")")
        fi
      done
    fi

    if [[ ${#packages[@]} -eq 0 ]]; then
      echo "No stow packages found in $PROJECT_DIR/stow"
      exit 0
    fi

    echo "Found packages: ${packages[*]}"
    echo "Running: stow --override=.* ${packages[*]}"
    stow --override=.* "${packages[@]}"
  else
    echo "Running stow with override: stow --override=.* $*"
    stow --override=.* "$@"
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

  if systemctl is-active --quiet fail2ban 2>/dev/null; then
    check_pass "Fail2ban is running"
  else
    check_warn "Fail2ban is not running"
  fi

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
    setup)
      cmd_setup
      ;;
    format)
      shift
      cmd_format "${1:-all}"
      ;;
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
    backup)
      cmd_backup
      ;;
    cleanup)
      shift
      cmd_cleanup "${1:-}"
      ;;
    doctor)
      cmd_doctor
      ;;
    diag)
      cmd_diag
      ;;
    list-gens)
      cmd_list_gens
      ;;
    trim)
      cmd_trim
      ;;
    add-host)
      shift
      cmd_add_host "${1:-}" "${2:-}"
      ;;
    del-host)
      shift
      cmd_del_host "${1:-}"
      ;;
    stow)
      cmd_stow "$@"
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
