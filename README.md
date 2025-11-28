# 🚀 NixOS Dotfiles

<div align="center">

A modular, declarative NixOS configuration with multi-GPU support and KDE Plasma
6

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![KDE Plasma](https://img.shields.io/badge/DE-KDE%20Plasma%206-1d99f3.svg?style=flat&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Home Manager](https://img.shields.io/badge/Home-Manager-blue.svg?style=flat)](https://github.com/nix-community/home-manager)

</div>

## ✨ Features

- 🎯 **Modular Design** - Clean separation between system, user, and hardware
  configurations
- 🖥️ **Multi-GPU Support** - Automatic GPU detection with profiles for AMD,
  Intel, NVIDIA, and hybrid setups
- 🎨 **KDE Plasma 6** - Modern desktop environment with SDDM display manager
- 🏠 **Home Manager** - Declarative dotfile and user environment management
- 🔐 **Secrets Management** - Age-encrypted secrets with agenix
- 📦 **Flatpak Integration** - Declarative Flatpak package management
- 🛠️ **Custom CLI** - Powerful `dot` command for system management
- 🔄 **Host-Specific** - Multiple machines with independent configurations
- ⚡ **Optimized** - SSD optimization, clean rebuilds, and automatic backup
  cleanup

## 📸 Screenshots

<div align="center">

![Desktop Screenshot](.github/desktop-screenshot.png)

_KDE Plasma 6 desktop environment with custom configuration_

</div>

## 🧰 Tech Stack

### Core System

- **OS**: NixOS (unstable channel)
- **Desktop Environment**: KDE Plasma 6
- **Display Manager**: SDDM (Wayland)
- **Package Manager**: Nix Flakes + Flatpak

### Development Tools

- **Terminal**: Ghostty (GPU-accelerated)
- **Editor**: Neovim (configured with [nvf](https://github.com/notashelf/nvf))
- **IDE**: Visual Studio Code
- **Shell**: ZSH with custom configuration
- **Version Control**: Git with per-host configuration

### CLI Utilities

- **File Navigation**: `eza` (ls replacement), `zoxide` (cd replacement), `fzf`
  (fuzzy finder)
- **File Viewing**: `bat` (cat replacement), `btop` (system monitor)
- **Git UI**: `lazygit`
- **Additional**: ripgrep, fd, tldr, and more

### GPU Drivers

- AMD (AMDGPU)
- Intel (integrated graphics)
- NVIDIA (proprietary)
- Hybrid configurations (NVIDIA + Intel/AMD)

## 🚀 Quick Start

### Prerequisites

- A fresh NixOS installation
- Git installed
- Root access (for initial setup)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the setup script**

   ```bash
   ./dot-setup.sh
   ```

   This will:
   - Auto-detect your hostname and GPU
   - Create host configuration from template
   - Copy hardware configuration
   - Add your host to `flake.nix`

3. **Customize your configuration**

   ```bash
   # Edit host-specific variables
   nvim hosts/$(hostname)/variables.nix
   ```

4. **Apply the configuration**

   ```bash
   sudo nixos-rebuild switch --flake .#$(hostname)
   ```

5. **Setup git hooks** (for clean commits)

   ```bash
   ln -sf ../../git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
   ```

After the first rebuild, use the `dot` command for all subsequent operations!

## 🎮 Usage

The `dot` command is your primary interface for managing the system:

### Basic Operations

```bash
# Rebuild current system
dot rebuild

# Rebuild with options
dot rebuild --dry        # Show what would be built
dot rebuild --ask        # Ask before performing actions
dot rebuild --cores 8    # Use 8 CPU cores
dot rebuild --verbose    # Show detailed output

# Rebuild for next boot (activates on restart)
dot rebuild-boot

# Update flake inputs and rebuild
dot update

# Clean old generations
dot cleanup

# List all generations
dot list-gens

# Generate system diagnostic report
dot diag

# Optimize SSD (fstrim)
dot trim
```

### Host Management

```bash
# Add a new host configuration
dot add-host mydesktop amd    # Explicitly specify GPU profile
dot add-host mylaptop         # Auto-detect GPU profile

# Remove a host configuration
dot del-host mydesktop
```

### Validation

```bash
# Always validate before committing changes!
nix flake check
```

## ⚙️ Configuration

### Host Variables

Each host has a `variables.nix` file for customization:

```nix
{
  # Personal settings
  gitUsername = "Your Name";

  # System settings
  keyboardLayout = "us,ru";
  consoleKeyMap = "us";
  printEnable = true;

  # Secrets
  sshKeyPath = "/home/username/.ssh/id_ed25519";
}
```

Sensitive data (like git email) is stored in encrypted secrets
(`secrets/*.age`).

### Adding Packages

**Host-specific packages:**

```bash
# Create or edit host-packages.nix
nvim hosts/$(hostname)/host-packages.nix
```

**System-wide packages:**

```bash
# Add to core packages
nvim modules/core/packages.nix
```

**User packages:**

```bash
# Add to home modules
nvim modules/home/cli-tools/  # or other appropriate location
```

### Customizing KDE Plasma

Currently configured via GUI System Settings. Future versions may use
[plasma-manager](https://github.com/nix-community/plasma-manager) for
declarative configuration.

## 📁 Project Structure

```
dotfiles/
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependency versions
├── dot-setup.sh           # Initial setup script
│
├── hosts/                 # Host-specific configurations
│   ├── laptop-82sn/
│   │   ├── default.nix           # Host imports
│   │   ├── hardware.nix          # Hardware configuration
│   │   ├── variables.nix         # Host customization
│   │   └── host-packages.nix     # Optional host packages
│   └── probook-450/
│       └── ...
│
├── profiles/              # GPU profile configurations
│   ├── amd/
│   ├── intel/
│   ├── nvidia/
│   ├── nvidia-laptop/
│   └── amd-hybrid/
│
├── modules/
│   ├── core/              # System-level modules
│   │   ├── boot/
│   │   ├── desktop/
│   │   │   ├── environments/
│   │   │   │   ├── plasma.nix    # KDE Plasma 6
│   │   │   │   └── xserver.nix   # X11 server
│   │   │   └── display-managers/
│   │   │       └── sddm.nix      # SDDM config
│   │   ├── network/
│   │   ├── security/
│   │   ├── services/
│   │   └── virtualization/
│   │
│   ├── home/              # Home-manager modules
│   │   ├── terminal/
│   │   │   └── ghostty.nix
│   │   ├── editors/
│   │   │   ├── nvf.nix           # Neovim
│   │   │   └── vscode.nix
│   │   ├── cli-tools/
│   │   │   ├── bat.nix
│   │   │   ├── eza.nix
│   │   │   ├── fzf.nix
│   │   │   └── ...
│   │   └── scripts/
│   │       └── dot.nix           # The `dot` command
│   │
│   └── drivers/           # GPU driver modules
│       ├── amd-drivers.nix
│       ├── intel-drivers.nix
│       └── nvidia-drivers.nix
│
├── secrets/               # Agenix encrypted secrets
│   └── *.age
│
├── git-hooks/            # Git hooks for commit quality
│   └── prepare-commit-msg
│
└── CLAUDE.md             # Developer documentation
```

## 🎯 GPU Profiles

The system automatically detects your GPU during setup, but you can also
manually specify profiles:

| Profile         | Hardware       | Use Case                                       |
| --------------- | -------------- | ---------------------------------------------- |
| `amd`           | AMD GPUs       | Desktop/laptop with AMD graphics               |
| `intel`         | Intel iGPU     | Laptops/systems with Intel integrated graphics |
| `nvidia`        | NVIDIA GPU     | Desktop with NVIDIA dedicated GPU              |
| `nvidia-laptop` | NVIDIA + Intel | Laptops with NVIDIA Optimus                    |
| `amd-hybrid`    | NVIDIA + AMD   | Hybrid AMD + NVIDIA setups                     |

Each profile automatically configures the appropriate drivers and settings.

## 🔧 Advanced Features

### Automatic Backup Cleanup

Home-manager creates backup files (`*.backup`) when it detects conflicts. The
`dot rebuild` command automatically cleans these up.

### Host Independence

Each host configuration is completely independent. Multiple machines can run
different GPU profiles and configurations from the same repository.

### Secrets Management

Sensitive data is encrypted using [agenix](https://github.com/ryantm/agenix):

```bash
# Edit encrypted secrets
agenix -e secrets/work-email.age
```

### Development Environment

Includes a full development setup with:

- Language servers and formatters
- Git configuration with per-host identity
- SSH configuration with encrypted credentials
- Docker and virtualization support (libvirt/QEMU)

---

<div align="center">

**⭐ Star this repo if you find it useful! ⭐**

Made with ❤️ and Nix

</div>
