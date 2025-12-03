# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

Dotfiles is a modular NixOS configuration system with support for multiple
hardware profiles (AMD, Intel, NVIDIA) and the KDE Plasma 6 desktop environment.
The configuration is designed to be host-specific, with each machine having its
own variables file for customization.

## Build & Development Commands

### Initial Setup: `./dot-setup.sh`

Run this script when setting up a new device (before the first rebuild):

- Auto-detects current hostname and GPU profile
- Creates host configuration from template
- Copies hardware config from `/etc/nixos` or generates new one
- Adds host to `flake.nix`
- Provides instructions for first rebuild

### Git Hooks Setup

After cloning the repository, set up git hooks to ensure commit message quality:

```bash
ln -sf ../../.github/git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
```

This installs a `prepare-commit-msg` hook that automatically strips `bat`
formatting artifacts from commit messages. This is necessary because `cat` is
aliased to `bat` on this system, which can add formatting when using heredocs
for commit messages.

The hook is stored in the version-controlled `.github/git-hooks/` directory and removes:

- Border characters (─────)
- Line numbers and separators (e.g., " 1 │")
- Header metadata (STDIN, Size, File)

This ensures clean, professional commit messages without manual cleanup.

### Primary CLI Tool: `dot`

The system is managed through the `dot` command (defined in
`modules/home/scripts/dot.nix`):

- **`dot rebuild`** - Rebuild and activate the NixOS configuration for current
  hostname
  - Automatically detects hostname - no manual configuration needed
  - Options: `--dry`, `--ask`, `--cores N`, `--verbose`, `--no-nom`
- **`dot rebuild-boot`** - Rebuild for next boot (activates on restart)
- **`dot update`** - Update flake inputs and rebuild for current hostname
- **`dot cleanup`** - Remove old system generations
- **`dot list-gens`** - List user and system generations
- **`dot diag`** - Generate system diagnostic report
- **`dot trim`** - Run fstrim for SSD optimization
- **`dot stow`** - Stage changes and rebuild

### Host Management

- **`dot add-host [hostname] [profile]`** - Create new host configuration
- **`dot del-host [hostname]`** - Remove host configuration

## Architecture

### Directory Structure

```
├── flake.nix                 # Main flake entry point
├── hosts/                    # Host-specific configurations
│   ├── laptop-82sn/          # AMD Ryzen 6800H + Radeon 680M
│   │   ├── default.nix       # Host-level imports and config
│   │   ├── hardware.nix      # Hardware-specific settings
│   │   ├── host-packages.nix # Host-specific packages
│   │   ├── performance.nix   # Performance optimizations (Zram, CPU)
│   │   └── variables.nix     # Host configuration variables
│   └── probook-450/          # Intel integrated graphics
│       └── ...
├── modules/
│   ├── core/                 # System-level modules
│   │   ├── default.nix       # Unconditionally imports all core modules
│   │   ├── boot/             # Bootloader configuration
│   │   ├── desktop/
│   │   │   ├── environments/
│   │   │   │   ├── plasma.nix    # KDE Plasma 6 system configuration
│   │   │   │   └── xserver.nix   # X11 server configuration
│   │   │   └── display-managers/
│   │   │       └── sddm.nix      # SDDM display manager
│   │   ├── desktop-apps/     # Flatpak, fonts, Steam
│   │   ├── hardware/         # Hardware configuration
│   │   ├── network/          # Networking and firewall
│   │   ├── packages/         # System packages
│   │   ├── security/         # Agenix secrets management
│   │   ├── services/         # System services (printing, syncthing, VPN)
│   │   ├── system/           # System-level settings
│   │   ├── tools/            # System tools (nh)
│   │   ├── user/             # User account configuration
│   │   └── virtualisation/   # Docker, libvirt/QEMU
│   ├── home/                 # Home-manager modules
│   │   ├── default.nix       # Unconditionally imports home modules
│   │   ├── apps/             # GUI applications (OBS, virt-manager)
│   │   ├── cli-tools/        # CLI utilities (bat, btop, eza, fzf, htop, etc.)
│   │   ├── config/           # Git, SSH, XDG configuration
│   │   ├── desktop/kde/      # Plasma-manager KDE configuration
│   │   │   ├── autostart.nix     # Application autostart
│   │   │   ├── config.nix        # KDE settings
│   │   │   ├── panels.nix        # Panel configuration
│   │   │   ├── wallpaper.nix     # Wallpaper settings
│   │   │   └── widgets.nix       # Desktop widgets
│   │   ├── editors/          # Code editors (nvf, vscode, zed)
│   │   ├── fastfetch/        # System info display
│   │   ├── scripts/          # Custom scripts (dot, vpn-tray)
│   │   ├── shell/zsh/        # ZSH configuration
│   │   └── terminal/         # Ghostty terminal
│   └── drivers/              # GPU driver configurations
│       ├── amd-drivers.nix
│       ├── intel-drivers.nix
│       ├── nvidia-drivers.nix
│       ├── nvidia-prime-drivers.nix
│       ├── nvidia-amd-hybrid.nix
│       └── local-hardware-clock.nix
├── profiles/                 # GPU profile configurations
│   ├── amd/
│   ├── intel/
│   ├── nvidia/
│   ├── nvidia-laptop/
│   └── amd-hybrid/
├── secrets/                  # Agenix encrypted secrets
│   ├── secrets.nix           # Secret definitions
│   └── *.age                 # Encrypted secret files
└── .github/
    └── git-hooks/            # Git hooks for commit quality
        └── prepare-commit-msg
```

### Configuration Flow

1. **`flake.nix`** defines:
   - `system` and `username` variables (shared across all hosts)
   - Inputs: nixpkgs, nixpkgs-pinned, home-manager, nix-flatpak, nvf,
     plasma-manager, agenix
   - The `mkNixosConfig` helper function:
     - Takes `gpuProfile` and `host` as parameters
     - Passes `inputs`, `username`, `host`, and `profile` as `specialArgs` to
       all modules
     - Creates a `nixosConfiguration` that imports the profile, nix-flatpak, and
       home-manager
   - Exports configurations named by hostname (e.g.,
     `nixosConfigurations.laptop-82sn`)
   - Each host configuration is independent and specifies its own GPU profile

2. **Profile Layer** (`profiles/{profile}/default.nix`):
   - Entry point that chains imports: host config → drivers → core modules
   - Enables GPU drivers via `drivers.amdgpu.enable = true` (driver module name
     may differ per profile)
   - Does not contain profile-specific logic; profile customization happens in
     driver modules

3. **Host Layer** (`hosts/{hostname}/`):
   - `variables.nix` contains all customization options (git config, keyboard,
     print settings)
   - `hardware.nix` contains hardware-specific configuration (generated by
     nixos-generate-config)
   - `default.nix` imports hardware config and optionally `host-packages.nix`
   - `host-packages.nix` (optional) - Host-specific packages
   - `performance.nix` (optional) - Host-specific performance tuning (Zram, CPU
     governor)

4. **Driver Layer** (`modules/drivers/`):
   - `default.nix` unconditionally imports all driver modules
   - Individual driver modules (e.g., `amd-drivers.nix`) define NixOS options
     that are disabled by default
   - Profiles enable specific drivers via `drivers.{driver}.enable = true`

5. **Core Modules** (`modules/core/default.nix`):
   - Unconditionally imports all system-level modules (boot, network, services,
     etc.)
   - Individual modules may use variables for conditional behavior
   - Handles system-level configuration (services, security, virtualization,
     etc.)

6. **Home-Manager Modules** (`modules/home/default.nix`):
   - Unconditionally imports all home modules
   - KDE configuration via plasma-manager (`desktop/kde/`)
   - Terminal emulator (ghostty) is directly imported
   - Editors (vscode, nvf, zed) are directly imported
   - Core modules (git, zsh, scripts, cli-tools) are always imported
   - No conditional imports - all modules are active

### Variables System

All host-specific customization happens through
`hosts/{hostname}/variables.nix`. The variables file is minimal and focused on
essential settings:

**Personal Settings:**

- `gitUsername` - Git user name (email is stored in encrypted secret)

**System Settings:**

- `keyboardLayout` - Keyboard layout (e.g., "us,ru" for US + Russian)
- `consoleKeyMap` - Console keyboard mapping
- `printEnable` - Enable printing support (true/false)
- `sshKeyPath` - Path to SSH private key for agenix secrets decryption

### Secrets Management (Agenix)

Sensitive information is stored in encrypted secrets managed by agenix in the
`secrets/` directory:

**VPN Credentials:**

- `bereke-username.age`, `bereke-password.age` - BerekeBank VPN credentials
- `bereke-totp-secret.age` - TOTP secret for auto-generating 2FA codes
- `bereke-gateway.age`, `bereke-dns.age`, `bereke-dns-search.age` - VPN network
  config
- `bereke-gitlab-hostname.age` - GitLab hostname
- `dahua-host.age`, `dahua-password.age`, `dahua-cert.age` - Dahua VPN
  credentials

**SSH Configuration:**

- `host-aq-ip.age`, `host-home-ip.age` - SSH host IP addresses
- `aq-username.age` - SSH username

**Work:**

- `work-email.age` - Work email address for git commits

**Managing secrets:**

```bash
# Edit an existing secret
agenix -e secrets/work-email.age

# Add a new secret
# 1. Add entry to secrets/secrets.nix
# 2. Run: agenix -e secrets/new-secret.age
```

### Module Import Pattern

The codebase uses unconditional imports for a streamlined configuration:

```nix
# In modules/home/default.nix
{
  imports = [
    # Configuration
    ./config/git.nix
    ./config/ssh.nix
    ./config/xdg.nix

    # Shell and scripts
    ./shell/zsh
    ./scripts

    # Terminal and editors
    ./terminal/ghostty.nix
    ./editors/nvf.nix
    ./editors/vscode.nix
    ./editors/zed.nix

    # CLI tools
    ./cli-tools/bat.nix
    ./cli-tools/btop.nix
    ./cli-tools/eza.nix
    ./cli-tools/fzf.nix
    ./cli-tools/htop.nix
    # ... and more

    # KDE Plasma configuration
    ./desktop/kde
  ];
}
```

**Key points:**

- All modules are imported directly without conditionals
- Individual modules may still reference variables for internal configuration
- This approach provides a consistent, fully-featured environment across all
  hosts
- Host-specific customization happens through `variables.nix` values, not module
  selection

### Desktop Configuration

The system is configured for desktop/laptop use with:

**Desktop Environment:**

- KDE Plasma 6 desktop environment with plasma-manager
- SDDM display manager (Wayland enabled)
- 6 virtual desktops with window rules
- Krohnkite tiling manager
- Night Color at 5500K temperature
- Round corners visual enhancement (8px)
- Full KDE application suite (Dolphin, Konsole, Kate, Spectacle, etc.)

**Autostart Applications:**

Configured in `modules/home/desktop/kde/autostart.nix`:

- Bitwarden (password manager)
- Telegram (Desktop 3)
- Brave browser (Desktop 1)
- ZapZap (WhatsApp Flatpak)
- Solaar (Logitech device manager)
- Joplin (note-taking)
- Thunderbird (Desktop 4)
- Zoom (Desktop 5)
- VPN Tray Indicator

**KWin Window Rules:**

Automatic window placement per desktop:

- Desktop 1: Brave browser
- Desktop 2: VSCode, Zed editor
- Desktop 3: Telegram
- Desktop 4: Thunderbird
- Desktop 5: Zoom
- Desktop 6: Camunda Modeler

**System Features:**

- Desktop applications (browsers, terminals, IDEs)
- Theming and appearance (BreezeDark color scheme)
- GUI system tools (Flatpak, fonts, Steam)
- Virtualization support (libvirt/QEMU)
- Optional printing support (controlled via `printEnable`)
- VPN integration with tray indicator

**CLI Environment:**

- Full CLI toolset: bat, btop, eza, fzf, htop, lazygit, zoxide
- Neovim with nvf configuration
- Ghostty terminal emulator
- Git, SSH, and ZSH configuration
- Custom scripts including `dot` management tool

Note: This configuration does not currently support server-only deployments. All
modules are oriented toward desktop/laptop use.

### KDE Plasma 6 Configuration

The system uses KDE Plasma 6 with plasma-manager for declarative configuration:

**System-level** (`modules/core/desktop/environments/plasma.nix`):

- Enables KDE Plasma 6 desktop environment
- Configures core Plasma packages (plasma-desktop, plasma-workspace)
- Installs KDE applications (Dolphin, Konsole, Kate, Ark, Okular, Gwenview,
  Spectacle)
- Sets up system integration (plasma-pa, plasma-nm, kscreen, bluedevil,
  powerdevil)
- Configures KWallet PAM integration for automatic wallet unlocking

**User-level** (`modules/home/desktop/kde/`):

- `autostart.nix` - Application autostart configuration
- `config.nix` - KDE settings (shortcuts, window rules, appearance)
- `panels.nix` - Panel layout and configuration
- `wallpaper.nix` - Wallpaper settings
- `widgets.nix` - Desktop widget configuration

**Display Manager** (`modules/core/desktop/display-managers/sddm.nix`):

- SDDM display manager with Wayland support
- Manages login screen and session selection

### VPN Integration

The system includes enterprise VPN support with automatic configuration:

**OpenConnect (BerekeBank):**

- Auto-TOTP generation using oath-toolkit
- Systemd service with automatic restart
- Encrypted credentials via agenix

**OpenFortiVPN (Dahua Dima):**

- Certificate-based authentication
- Systemd service management

**VPN Tray Indicator:**

- PyQt6 system tray application (`modules/home/scripts/vpn-tray.nix`)
- Connect/disconnect functionality
- Real-time status display
- Autostart on login

**Passwordless sudo for VPN:**

Configured in `modules/core/services/vpn.nix` for service management without
password prompts.

### Performance Optimizations

Host-specific performance tuning in `hosts/{hostname}/performance.nix`:

**Zram Swap (laptop-82sn):**

- zstd compression algorithm
- 50% of RAM allocated
- Higher swap priority than disk

**CPU Governor:**

- schedutil governor for balanced performance/power

**Kernel Tuning:**

- Network performance optimizations for VPN stability
- SSD fstrim weekly schedule

**Hardware Acceleration (AMD):**

- VA-API and VDPAU with radeonsi
- Environment variables for video acceleration

### GPU Profile System

GPU profiles are defined in `profiles/` and each host specifies its profile in
`flake.nix`. Each profile:

- Has a corresponding directory in `profiles/{profile}/` with a `default.nix`
- Enables specific GPU drivers from `modules/drivers/`
- Is specified per-host in the `nixosConfigurations` section

**Currently available profiles:**

- **amd** - AMD GPU drivers (laptop-82sn)
- **intel** - Intel integrated graphics (probook-450)
- **nvidia** - NVIDIA dedicated GPU
- **nvidia-laptop** - NVIDIA + Intel hybrid (laptops)
- **amd-hybrid** - NVIDIA + AMD hybrid

**Profile workflow:**

1. Each host in `flake.nix` specifies its `gpuProfile` parameter
2. The profile directory in `profiles/` enables the appropriate driver module
3. `./dot-setup.sh` or `dot add-host` auto-detect GPU hardware using `lspci`
4. Each host configuration is independent - multiple hosts with different
   profiles can coexist

## Key Implementation Details

### SDDM Configuration

- KDE Plasma uses SDDM (Simple Desktop Display Manager) as the display manager
- Wayland is enabled by default
- SDDM is configured in `modules/core/desktop/display-managers/sddm.nix`
- Supports both Wayland and X11 sessions

### Terminal Management

The system uses Ghostty as the primary terminal emulator:

- **Ghostty** (`modules/home/terminal/ghostty.nix`) - Modern GPU-accelerated
  terminal
  - Configured with 95% opacity for transparency
  - Shift+Enter keybinding for newline support (useful for Claude Code)
  - Window management, tab control, and scrolling keybindings
  - Unconditionally imported and always available

### Hostname-Aware Rebuilds

The `dot` tool automatically detects the current hostname and rebuilds the
corresponding configuration. Each host can run `dot rebuild` independently
without any manual configuration changes or conflicts.

### Home-Manager Integration

Home-manager is integrated at the NixOS configuration level with:

- `useUserPackages = true`
- `useGlobalPkgs = false`
- `backupFileExtension = "backup"`
- Backup file cleanup handled by `dot` via `handle_backups()`

## Modifying the Configuration

### Adding a New Host

**For a fresh NixOS installation (before first rebuild):**

1. Clone the dotfiles repository
2. Run `./dot-setup.sh` from the dotfiles directory
   - Auto-detects hostname and GPU profile
   - Creates host configuration in `hosts/{hostname}/`
   - Copies hardware config from `/etc/nixos` or generates new one
   - Adds host to `flake.nix`
3. Edit `hosts/{hostname}/variables.nix` to customize settings
4. Run first rebuild: `sudo nixos-rebuild switch --flake .#{hostname}`
5. After first rebuild, use `dot rebuild` for subsequent rebuilds

**For an existing system with `dot` already installed:**

1. Run `dot add-host {hostname} {profile}` (auto-detects profile if omitted)
   - Creates directory structure in `hosts/{hostname}/`
   - Auto-detects GPU profile or uses provided profile
   - Generates `variables.nix`, `hardware.nix`, and `default.nix`
   - Adds host to `flake.nix`
2. Edit `hosts/{hostname}/variables.nix` to customize settings
3. Run `dot rebuild` to build and activate the configuration

### Customizing Applications

Application configuration is done through module files rather than
enable/disable toggles:

1. **For host-specific packages**: Add packages to
   `hosts/{hostname}/host-packages.nix` (optional file)
2. **For system-wide packages**: Add to `modules/core/packages/` or
   `modules/core/tools/packages.nix`
3. **For user packages**: Modules in `modules/home/` are all imported
   unconditionally
4. Run `dot rebuild` to apply changes

**Note**: All modules in `modules/home/` and `modules/core/` are unconditionally
imported. To exclude functionality, comment out the import in the respective
`default.nix` file.

### Customizing KDE Plasma Behavior

KDE Plasma configuration is done through plasma-manager in
`modules/home/desktop/kde/`:

- **`config.nix`**: Shortcuts, window rules, general KDE settings
- **`autostart.nix`**: Application autostart configuration
- **`panels.nix`**: Panel layout and widgets
- **`wallpaper.nix`**: Desktop wallpaper settings
- **`widgets.nix`**: Desktop widget configuration

For settings not yet in plasma-manager, use GUI System Settings:

- **Appearance**: Themes, colors, icons, fonts
- **Workspace Behavior**: Window management, activities, virtual desktops
- **Input Devices**: Keyboard, mouse, touchpad settings

## Validation and Troubleshooting

### Pre-rebuild Validation

**IMPORTANT**: Always validate the configuration before rebuilding or
committing:

```bash
nix flake check
```

This checks:

- Flake syntax correctness
- NixOS configuration evaluation
- All imports are valid
- No obvious configuration errors

**When to run `nix flake check`:**

- Before every `git commit` (mandatory)
- Before `dot rebuild` (recommended)
- After modifying any `.nix` file
- After adding/removing modules or changing imports

### Rebuild Troubleshooting

If `dot rebuild` fails:

1. **Check hostname mismatch**: Ensure `hostname` matches `host` variable in
   `flake.nix`
   - Run `hostname` to see current hostname

2. **Review variables.nix**: Ensure all paths and values are correct

3. **Check for syntax errors**: Run `nix flake check` for detailed error
   messages

4. **Review recent changes**: Use `git diff` to see what changed since last
   successful rebuild

5. **Rollback if needed**: Previous generations are available in the boot menu

### Common Issues

- **"hostname mismatch" error**: `dot` verifies hostname before rebuild
- **Home-manager backup files**: Automatically cleaned by `dot` rebuild process
- **Failed flake check**: Often indicates missing imports or syntax errors in
  `.nix` files
- **VPN connection issues**: Check secrets decryption and service status with
  `systemctl status openconnect-bereke`

## Adding New Features

### Adding a New Application Module

1. Create a new module file in `modules/home/{category}/{app}.nix` or
   `modules/core/{category}/{app}.nix`
2. Add import to `modules/home/default.nix` or `modules/core/default.nix`
3. Run `nix flake check` to validate syntax
4. Run `dot rebuild` to build and test

**Example home module** (`modules/home/cli-tools/myapp.nix`):

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    myapp
  ];
}
```

### Adding a New Secret

1. Add the secret definition to `secrets/secrets.nix`:

   ```nix
   "new-secret.age".publicKeys = [ user1 ];
   ```

2. Create the encrypted secret:

   ```bash
   agenix -e secrets/new-secret.age
   ```

3. Reference in modules via `config.age.secrets.new-secret.path`

### Adding a New GPU Profile

1. Create `profiles/{profile}/default.nix` with imports structure
2. Create driver module in `modules/drivers/{driver}-drivers.nix` with enable
   option
3. Enable the driver in the profile: `drivers.{driver}.enable = true`
4. Add host to `flake.nix` with `mkNixosConfig "{profile}" "{hostname}"`
5. Update `dot add-host` GPU detection logic in `modules/home/scripts/dot.nix`

## Important Conventions

1. **KDE Plasma 6** - This configuration uses KDE Plasma 6 with plasma-manager
2. **Plasma-manager** - Declarative KDE configuration in
   `modules/home/desktop/kde/`
3. **Unconditional imports** - All modules are imported unconditionally
4. **Host-specific settings** - Minimal customization in
   `hosts/{hostname}/variables.nix`
5. **GPU profiles** - Match the profile to hardware or use auto-detection
6. **Backup cleanup** - Home-manager backup files are automatically cleaned by
   `dot rebuild`
7. **Terminal** - Ghostty is the configured terminal emulator
8. **Module organization** - System-level config in `modules/core/`, user config
   in `modules/home/`
9. **Secrets** - All sensitive data encrypted with agenix in `secrets/`
10. **Pre-commit validation** - ALWAYS run `nix flake check` before creating any
    git commit
11. **Git commit messages** - Do not include "Generated with Claude Code" or
    "Co-Authored-By: Claude" signatures in commit messages
12. **Package search** - Use `nh search` to find packages

### Current Hosts

| Hostname     | GPU Profile | Hardware                       |
| ------------ | ----------- | ------------------------------ |
| laptop-82sn  | amd         | AMD Ryzen 6800H + Radeon 680M  |
| probook-450  | intel       | Intel integrated graphics      |
