# NixOS Dotfiles

<div align="center">

A modular, declarative NixOS configuration with multi-GPU support and KDE Plasma
6

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![KDE Plasma](https://img.shields.io/badge/DE-KDE%20Plasma%206-1d99f3.svg?style=flat&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Home Manager](https://img.shields.io/badge/Home-Manager-blue.svg?style=flat)](https://github.com/nix-community/home-manager)

![Desktop Screenshot](.github/desktop-screenshot.png)

</div>

## Features

- **Modular Design** - Clean separation between system, user, and hardware
  configurations
- **Multi-GPU Support** - Automatic GPU detection with profiles for AMD, Intel,
  NVIDIA, and hybrid setups
- **KDE Plasma 6** - Declarative desktop configuration with plasma-manager
- **Home Manager** - Declarative dotfile and user environment management
- **Secrets Management** - Age-encrypted secrets with agenix
- **VPN Integration** - Enterprise VPN support with auto-TOTP and tray indicator
- **Flatpak Integration** - Declarative Flatpak package management
- **Custom CLI** - Powerful `dot` command for system management
- **Host-Specific** - Multiple machines with independent configurations
- **Performance Tuning** - Zram, CPU governor, and kernel optimizations
- **Self-Hosted Services** - Vaultwarden (Bitwarden) and Joplin Server for servers

## Tech Stack

### Core System

- **OS**: NixOS (unstable channel)
- **Desktop Environment**: KDE Plasma 6 with plasma-manager
- **Display Manager**: SDDM (Wayland)
- **Package Manager**: Nix Flakes + Flatpak
- **Secrets**: Agenix

### Development Tools

- **Terminal**: Ghostty (GPU-accelerated)
- **Editor**: Neovim (configured with [nvf](https://github.com/notashelf/nvf))
- **IDE**: Visual Studio Code, Zed
- **Shell**: ZSH with custom configuration
- **Version Control**: Git with per-host configuration

### CLI Utilities

- **File Navigation**: `eza` (ls replacement), `zoxide` (cd replacement), `fzf`
  (fuzzy finder)
- **File Viewing**: `bat` (cat replacement), `btop` (system monitor), `htop`
- **Git UI**: `lazygit`
- **Additional**: ripgrep, fd, tldr, and more

### GPU Drivers

- AMD (AMDGPU)
- Intel (integrated graphics)
- NVIDIA (proprietary)
- Hybrid configurations (NVIDIA + Intel/AMD)

## Quick Start

### Prerequisites

- A fresh NixOS installation
- Git installed
- Root access (for initial setup)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/Documents/dotfiles
   cd ~/Documents/dotfiles
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
   nvim hosts/$(hostname)/variables.nix
   ```

4. **Apply the configuration**

   ```bash
   sudo nixos-rebuild switch --flake .#$(hostname)
   ```

5. **Setup git hooks** (for clean commits)

   ```bash
   ln -sf ../../.github/git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
   ```

After the first rebuild, use the `dot` command for all subsequent operations!

## Usage

The `dot` command is your primary interface for managing the system:

### Basic Operations

```bash
dot rebuild              # Rebuild current system
dot rebuild --dry        # Show what would be built
dot rebuild --ask        # Ask before performing actions
dot rebuild --cores 8    # Use 8 CPU cores
dot rebuild --verbose    # Show detailed output
dot rebuild-boot         # Rebuild for next boot
dot update               # Update flake inputs and rebuild
dot cleanup              # Clean old generations
dot list-gens            # List all generations
dot diag                 # Generate system diagnostic report
dot trim                 # Optimize SSD (fstrim)
dot stow                 # Stage changes and rebuild
```

### Host Management

```bash
dot add-host mydesktop amd    # Explicitly specify GPU profile
dot add-host mylaptop         # Auto-detect GPU profile
dot del-host mydesktop        # Remove a host configuration
```

### Validation

```bash
nix flake check    # Always validate before committing!
```

## Architecture

### Directory Structure

```
dotfiles/
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependency versions
├── dot-setup.sh           # Initial setup script
│
├── hosts/                 # Host-specific configurations
│   ├── laptop-82sn/       # AMD Ryzen 6800H + Radeon 680M
│   │   ├── default.nix
│   │   ├── hardware.nix
│   │   ├── variables.nix
│   │   ├── host-packages.nix
│   │   └── performance.nix
│   └── probook-450/       # Intel integrated graphics
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
│   │   ├── default.nix    # Conditionally imports based on deviceType
│   │   ├── boot/          # Bootloader configuration
│   │   ├── desktop/
│   │   │   ├── environments/
│   │   │   │   ├── plasma.nix    # KDE Plasma 6 system config
│   │   │   │   └── xserver.nix   # X11 server configuration
│   │   │   └── display-managers/
│   │   │       └── sddm.nix      # SDDM display manager
│   │   ├── desktop-apps/  # Flatpak, fonts, Steam
│   │   ├── hardware/      # Hardware configuration
│   │   ├── network/       # Networking and firewall
│   │   ├── packages/      # System packages
│   │   ├── security/      # Agenix secrets management
│   │   ├── services/      # System services (printing, syncthing, VPN)
│   │   ├── system/        # System-level settings
│   │   ├── tools/         # System tools (nh)
│   │   ├── user/          # User account configuration
│   │   └── virtualisation/ # Docker, libvirt/QEMU
│   │
│   ├── home/              # Home-manager modules
│   │   ├── default.nix    # Conditionally imports based on deviceType
│   │   ├── apps/          # GUI applications (OBS, virt-manager)
│   │   ├── cli-tools/     # CLI utilities (bat, btop, eza, fzf, htop, etc.)
│   │   ├── config/        # Git, SSH, XDG configuration
│   │   ├── desktop/kde/   # Plasma-manager KDE configuration
│   │   │   ├── autostart.nix     # Application autostart
│   │   │   ├── config.nix        # KDE settings
│   │   │   ├── panels.nix        # Panel configuration
│   │   │   ├── wallpaper.nix     # Wallpaper settings
│   │   │   └── widgets.nix       # Desktop widgets
│   │   ├── editors/       # Code editors (nvf, vscode, zed)
│   │   ├── fastfetch/     # System info display
│   │   ├── scripts/       # Custom scripts (dot, vpn-tray)
│   │   ├── shell/zsh/     # ZSH configuration
│   │   └── terminal/      # Ghostty terminal
│   │
│   └── drivers/           # GPU driver configurations
│       ├── amd-drivers.nix
│       ├── intel-drivers.nix
│       ├── nvidia-drivers.nix
│       ├── nvidia-prime-drivers.nix
│       ├── nvidia-amd-hybrid.nix
│       └── local-hardware-clock.nix
│
├── secrets/               # Agenix encrypted secrets
│   ├── secrets.nix        # Secret definitions
│   └── *.age              # Encrypted secret files
│
├── .github/
│   └── git-hooks/         # Git hooks for commit quality
│       └── prepare-commit-msg
│
└── CLAUDE.md              # Claude Code instructions
```

### Configuration Flow

1. **`flake.nix`** defines:
   - `system` and `username` variables (shared across all hosts)
   - Inputs: nixpkgs, nixpkgs-pinned, home-manager, nix-flatpak, nvf,
     plasma-manager, agenix
   - The `mkNixosConfig` helper function that takes `gpuProfile` and `host`
     parameters
   - Passes `inputs`, `username`, `host`, and `profile` as `specialArgs` to all
     modules
   - Exports configurations named by hostname (e.g.,
     `nixosConfigurations.laptop-82sn`)

2. **Profile Layer** (`profiles/{profile}/default.nix`):
   - Entry point that chains imports: host config → drivers → core modules
   - Enables GPU drivers via `drivers.amdgpu.enable = true`

3. **Host Layer** (`hosts/{hostname}/`):
   - `variables.nix` - All customization options
   - `hardware.nix` - Hardware-specific configuration
   - `default.nix` - Imports hardware config and optionally host-packages.nix
   - `host-packages.nix` (optional) - Host-specific packages
   - `performance.nix` (optional) - Performance tuning

4. **Driver Layer** (`modules/drivers/`):
   - Individual driver modules with enable options (disabled by default)
   - Profiles enable specific drivers

5. **Core Modules** (`modules/core/default.nix`):
   - Conditionally imports modules based on `deviceType`
   - Server-compatible modules always loaded
   - Desktop modules only when `deviceType != "server"`

6. **Home-Manager Modules** (`modules/home/default.nix`):
   - Core modules (git, zsh, scripts, cli-tools) always imported
   - Desktop modules conditional on `deviceType`

## Configuration

### Host Variables

Each host has a `variables.nix` file with these settings:

| Variable         | Description                  | Example                        |
| ---------------- | ---------------------------- | ------------------------------ |
| `gitUsername`    | Git user name                | `"Your Name"`                  |
| `deviceType`     | Device type                  | `"laptop"` or `"server"`       |
| `keyboardLayout` | Keyboard layout              | `"us,ru"`                      |
| `consoleKeyMap`  | Console keyboard             | `"us"`                         |
| `printEnable`    | Enable printing              | `true`/`false`                 |
| `workEnable`     | Enable company work features | `true`/`false`                 |
| `sshKeyPath`     | SSH key for agenix           | `"/home/user/.ssh/id_ed25519"` |

### Device Type System

The `deviceType` variable controls which modules are loaded:

**`"laptop"`** (default):

- Full desktop environment with KDE Plasma 6
- GUI applications, gaming support, audio (pipewire)
- GUI editors (VSCode, Zed), Ghostty terminal
- VPN tray indicator, Flatpak support

**`"server"`**:

- Minimal configuration with CLI tools only
- Docker, SSH, development tools
- No GUI, audio, or gaming support
- Neovim (nvf) as TUI editor

### Module Import Pattern

```nix
# In modules/home/default.nix
{
  lib,
  host,
  ...
}:
let
  vars = import ../../hosts/${host}/variables.nix;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";
in
{
  imports =
    [
      # Always loaded (server-compatible)
      ./config/git.nix
      ./shell/zsh
      ./cli-tools/bat.nix
      ./editors/nvf.nix
    ]
    ++ lib.optionals (!isServer) [
      # Desktop/laptop only
      ./editors/vscode.nix
      ./terminal/ghostty.nix
      ./desktop/kde
    ];
}
```

## GPU Profiles

| Profile         | Hardware       | Use Case                          |
| --------------- | -------------- | --------------------------------- |
| `amd`           | AMD GPUs       | Desktop/laptop with AMD graphics  |
| `intel`         | Intel iGPU     | Intel integrated graphics         |
| `nvidia`        | NVIDIA GPU     | Desktop with NVIDIA dedicated GPU |
| `nvidia-laptop` | NVIDIA + Intel | Laptops with NVIDIA Optimus       |
| `amd-hybrid`    | NVIDIA + AMD   | Hybrid AMD + NVIDIA setups        |

GPU is automatically detected during setup, or you can specify it manually with
`dot add-host hostname profile`.

## Secrets Management

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix):

```bash
# Edit existing secret
agenix -e secrets/work-email.age

# Add new secret
# 1. Add entry to secrets/secrets.nix:
#    "new-secret.age".publicKeys = [ user1 ];
# 2. Create the secret:
agenix -e secrets/new-secret.age
```

**Available secrets:**

- VPN credentials (`bereke-*.age`, `dahua-*.age`)
- SSH configuration (`host-*.age`, `aq-username.age`)
- Work email (`work-email.age`)

Reference in modules: `config.age.secrets.secret-name.path`

## Desktop Environment

When `deviceType = "laptop"`:

### KDE Plasma 6 Features

- 6 virtual desktops with window rules
- Krohnkite tiling manager
- Night Color at 5500K temperature
- Round corners (8px)
- BreezeDark color scheme

### Autostart Applications

- Bitwarden, Telegram, Brave browser
- ZapZap (WhatsApp), Solaar, Joplin
- Thunderbird, Zoom, VPN Tray Indicator

### KWin Window Rules

| Desktop | Applications       |
| ------- | ------------------ |
| 1       | Brave browser      |
| 2       | VSCode, Zed editor |
| 3       | Telegram           |
| 4       | Thunderbird        |
| 5       | Zoom               |
| 6       | Camunda Modeler    |

## VPN Integration

### OpenConnect (BerekeBank)

- Auto-TOTP generation using oath-toolkit
- Systemd service with automatic restart
- Encrypted credentials via agenix

### OpenFortiVPN (Dahua)

- Certificate-based authentication
- Systemd service management

### VPN Tray Indicator

- PyQt6 system tray application
- Connect/disconnect functionality
- Real-time status display
- Passwordless sudo for VPN services

## Performance Optimizations

### Zram Swap

- zstd compression algorithm
- 50% of RAM allocated
- Higher swap priority than disk

### CPU Governor

- schedutil for balanced performance/power

### Kernel Tuning

- Network optimizations for VPN stability
- SSD fstrim weekly schedule

### Hardware Acceleration (AMD)

- VA-API and VDPAU with radeonsi
- Environment variables for video acceleration

## Modifying the Configuration

### Adding a New Host

**Fresh installation:**

1. Clone repository
2. Run `./dot-setup.sh`
3. Edit `hosts/{hostname}/variables.nix`
4. Run `sudo nixos-rebuild switch --flake .#{hostname}`

**Existing system:**

1. Run `dot add-host {hostname} {profile}`
2. Edit `hosts/{hostname}/variables.nix`
3. Run `dot rebuild`

### Adding Packages

| Location                             | Use Case               |
| ------------------------------------ | ---------------------- |
| `hosts/{hostname}/host-packages.nix` | Host-specific packages |
| `modules/core/packages/`             | System-wide packages   |
| `modules/home/cli-tools/`            | User CLI tools         |

### Customizing KDE Plasma

Edit files in `modules/home/desktop/kde/`:

- `config.nix` - Shortcuts, window rules, appearance
- `autostart.nix` - Application autostart
- `panels.nix` - Panel layout and widgets
- `wallpaper.nix` - Desktop wallpaper
- `widgets.nix` - Desktop widgets

## Troubleshooting

### Common Issues

| Issue                 | Solution                                                |
| --------------------- | ------------------------------------------------------- |
| Hostname mismatch     | Run `hostname` to verify, ensure it matches `flake.nix` |
| Backup file conflicts | Automatically cleaned by `dot rebuild`                  |
| Failed flake check    | Check for missing imports or syntax errors              |
| VPN issues            | Check `systemctl status openconnect-bereke`             |

### Rebuild Troubleshooting

1. Run `nix flake check` for detailed errors
2. Review `git diff` for recent changes
3. Rollback via boot menu if needed

## Current Hosts

| Hostname    | Type   | GPU   | Hardware                      |
| ----------- | ------ | ----- | ----------------------------- |
| laptop-82sn | laptop | amd   | AMD Ryzen 6800H + Radeon 680M |
| probook-450 | laptop | intel | Intel integrated graphics     |
| ninkear     | server | amd   | AMD server                    |

## Self-Hosted Services

When `deviceType = "server"`, the following services are automatically enabled:

### Vaultwarden (Bitwarden-compatible)

Self-hosted password manager compatible with Bitwarden clients.

| Setting          | Value                    |
| ---------------- | ------------------------ |
| Port             | 8222                     |
| URL              | `http://localhost:8222`  |
| Signups          | Disabled                 |
| Backup Directory | `/var/backup/vaultwarden`|

Access the web vault at the configured URL. Use any Bitwarden client (mobile, desktop, browser extension) by pointing it to your server's address.

### Joplin Server

Self-hosted sync server for Joplin note-taking application, running via Docker.

| Component       | Details                          |
| --------------- | -------------------------------- |
| Port            | 22300                            |
| URL             | `http://localhost:22300`         |
| Database        | PostgreSQL 16                    |
| Docker Network  | `joplin-network`                 |

**Containers:**
- `joplin-db` - PostgreSQL database for Joplin
- `joplin-server` - Joplin sync server

Configure your Joplin desktop/mobile clients to sync with the server URL.

---

<div align="center">

Made with Nix

</div>
