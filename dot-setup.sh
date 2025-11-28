#!/usr/bin/env bash
set -euo pipefail

# dot-setup.sh - New Device Setup Script
# Run this script on a fresh NixOS installation to set up dotfiles

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_HOSTNAME=$(hostname)

# --- Helper Functions ---
detect_gpu_profile() {
  local detected_profile=""
  local has_nvidia=false
  local has_intel=false
  local has_amd=false
  local has_vm=false

  if lspci &>/dev/null; then
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
  fi
  echo "$detected_profile"
}

print_banner() {
  echo "========================================"
  echo "  Dotfiles Setup - New Device Wizard"
  echo "========================================"
  echo ""
}

# --- Main Script ---
print_banner

echo "Current hostname: $CURRENT_HOSTNAME"
echo "Dotfiles directory: $SCRIPT_DIR"
echo ""

# Check if configuration exists for this hostname
if [ -d "$SCRIPT_DIR/hosts/$CURRENT_HOSTNAME" ]; then
  echo "✓ Configuration found for '$CURRENT_HOSTNAME'"
  echo ""

  # Check if nixosConfiguration exists in flake.nix
  if grep -q "^[[:space:]]*$CURRENT_HOSTNAME[[:space:]]*=" "$SCRIPT_DIR/flake.nix"; then
    echo "✓ NixOS configuration found in flake.nix"
    echo ""
    echo "This device is already set up. You can now run:"
    echo "  sudo nixos-rebuild switch --flake .#$CURRENT_HOSTNAME"
    echo ""
    echo "Or if you have 'dot' installed:"
    echo "  dot rebuild"
    echo ""
    read -p "Would you like to rebuild now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Starting rebuild..."
      cd "$SCRIPT_DIR"
      sudo nixos-rebuild switch --flake ".#$CURRENT_HOSTNAME"
    fi
  else
    echo "⚠ Warning: Host folder exists but no nixosConfiguration in flake.nix"
    echo ""
    echo "Please add the following to flake.nix nixosConfigurations:"
    echo ""
    echo "  $CURRENT_HOSTNAME = mkNixosConfig {"
    echo "    gpuProfile = \"<profile>\";"
    echo "    host = \"$CURRENT_HOSTNAME\";"
    echo "  };"
    echo ""
  fi
  exit 0
fi

echo "✗ No configuration found for '$CURRENT_HOSTNAME'"
echo ""
echo "Let's set up this device!"
echo ""

# Detect GPU profile
echo "Detecting GPU profile..."
DETECTED_PROFILE=$(detect_gpu_profile)

if [ -n "$DETECTED_PROFILE" ]; then
  echo "Detected GPU profile: $DETECTED_PROFILE"
else
  echo "Could not auto-detect GPU profile."
  DETECTED_PROFILE="intel" # default fallback
  echo "Using default: $DETECTED_PROFILE"
fi
echo ""

read -p "Is '$DETECTED_PROFILE' correct? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "Available profiles:"
  echo "  - intel"
  echo "  - amd"
  echo "  - nvidia"
  echo "  - nvidia-laptop (NVIDIA + Intel hybrid)"
  echo "  - amd-hybrid (NVIDIA + AMD hybrid)"
  echo "  - vm (virtual machine)"
  echo ""
  read -p "Enter the correct profile: " DETECTED_PROFILE
fi

echo ""

# Ask about system type (laptop/desktop or server)
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

echo ""
echo "Creating host configuration for '$CURRENT_HOSTNAME' with profile '$DETECTED_PROFILE' as '$SYSTEM_TYPE'..."

# Copy default host configuration
if [ ! -d "$SCRIPT_DIR/hosts/default" ]; then
  echo "Error: Default host template not found at $SCRIPT_DIR/hosts/default" >&2
  exit 1
fi

cp -r "$SCRIPT_DIR/hosts/default" "$SCRIPT_DIR/hosts/$CURRENT_HOSTNAME"
echo "✓ Copied default configuration"

# Update systemType in variables.nix based on user selection
sed -i "s/systemType = \"laptop\";/systemType = \"$SYSTEM_TYPE\";/" "$SCRIPT_DIR/hosts/$CURRENT_HOSTNAME/variables.nix"
echo "✓ Set systemType to '$SYSTEM_TYPE'"

# Try to get hardware.nix from /etc/nixos first
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
  echo "Found existing hardware configuration at /etc/nixos/hardware-configuration.nix"
  read -p "Use existing hardware configuration? (Y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    cp /etc/nixos/hardware-configuration.nix "$SCRIPT_DIR/hosts/$CURRENT_HOSTNAME/hardware.nix"
    echo "✓ Copied hardware.nix from /etc/nixos"
  else
    echo "Generating new hardware.nix..."
    sudo nixos-generate-config --show-hardware-config >"$SCRIPT_DIR/hosts/$CURRENT_HOSTNAME/hardware.nix"
    echo "✓ Generated new hardware.nix"
  fi
else
  echo "Generating hardware.nix..."
  sudo nixos-generate-config --show-hardware-config >"$SCRIPT_DIR/hosts/$CURRENT_HOSTNAME/hardware.nix"
  echo "✓ Generated hardware.nix"
fi

# Add nixosConfiguration to flake.nix
echo "Adding configuration to flake.nix..."

# Find the line with the closing brace of nixosConfigurations and insert before it
# We need to be careful with sed to insert properly
if grep -q "^[[:space:]]*};[[:space:]]*$" "$SCRIPT_DIR/flake.nix"; then
  # Create a temporary file with the new entry
  NEW_ENTRY="        $CURRENT_HOSTNAME = mkNixosConfig {
          gpuProfile = \"$DETECTED_PROFILE\";
          host = \"$CURRENT_HOSTNAME\";
        };"

  # Insert before the last occurrence of closing brace in nixosConfigurations
  sed -i "/^[[:space:]]*};[[:space:]]*$/i\\$NEW_ENTRY" "$SCRIPT_DIR/flake.nix"

  echo "✓ Added to flake.nix"
else
  echo "⚠ Warning: Could not automatically add to flake.nix"
  echo ""
  echo "Please manually add the following to nixosConfigurations in flake.nix:"
  echo ""
  echo "  $CURRENT_HOSTNAME = mkNixosConfig {"
  echo "    gpuProfile = \"$DETECTED_PROFILE\";"
  echo "    host = \"$CURRENT_HOSTNAME\";"
  echo "  };"
  echo ""
fi

# --- Set up git hooks ---
echo ""
echo "Setting up git hooks..."
if [ -f "$SCRIPT_DIR/git-hooks/prepare-commit-msg" ]; then
  ln -sf ../../git-hooks/prepare-commit-msg "$SCRIPT_DIR/.git/hooks/prepare-commit-msg"
  echo "✓ Git hooks installed (commit message cleanup)"
else
  echo "⚠ Warning: git-hooks/prepare-commit-msg not found, skipping hook setup"
fi

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Review and customize:"
echo "     $SCRIPT_DIR/hosts/$CURRENT_HOSTNAME/variables.nix"
echo ""
echo "  2. Run the first rebuild:"
echo "     cd $SCRIPT_DIR"
echo "     sudo nixos-rebuild switch --flake .#$CURRENT_HOSTNAME"
echo ""
echo "  3. After the rebuild, you can use the 'dot' command:"
echo "     dot rebuild"
echo ""
