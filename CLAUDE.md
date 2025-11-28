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
ln -sf ../../git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
```

This installs a `prepare-commit-msg` hook that automatically strips `bat`
formatting artifacts from commit messages. This is necessary because `cat` is
aliased to `bat` on this system, which can add formatting when using heredocs
for commit messages.

The hook is stored in the version-controlled `git-hooks/` directory and removes:

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

### Host Management

- **`dot add-host [hostname] [profile]`** - Create new host configuration
- **`dot del-host [hostname]`** - Remove host configuration

## Architecture

### Directory Structure

```
├── flake.nix                 # Main flake entry point
├── hosts/                    # Host-specific configurations
│   └── {hostname}/
│       ├── default.nix       # Host-level imports and config
│       ├── hardware.nix      # Hardware-specific settings
│       ├── host-packages.nix # Host-specific packages (optional)
│       └── variables.nix     # Host configuration variables
├── modules/
│   ├── core/                 # System-level modules
│   │   ├── default.nix       # Unconditionally imports all core modules
│   │   ├── desktop/
│   │   │   └── environments/
│   │   │       ├── plasma.nix    # KDE Plasma 6 system configuration
│   │   │       └── xserver.nix   # X11 server configuration
│   │   ├── desktop/
│   │   │   └── display-managers/
│   │   │       └── sddm.nix      # SDDM display manager
│   │   ├── packages.nix      # System packages
│   │   └── ...               # Services, security, virtualization, etc.
│   ├── home/                 # Home-manager modules
│   │   ├── default.nix       # Unconditionally imports home modules
│   │   ├── terminal/
│   │   │   └── ghostty.nix   # Ghostty terminal configuration
│   │   ├── editors/          # Code editors (nvf, vscode)
│   │   ├── cli-tools/        # CLI utilities (bat, eza, fzf, lazygit, etc.)
│   │   └── ...               # Scripts, shell config, theming
│   └── drivers/              # GPU driver configurations
│       ├── amd-drivers.nix
│       └── ...
└── profiles/                 # GPU profile configurations
    └── {profile}/
        └── default.nix       # Profile-specific imports
```

### Configuration Flow

1. **`flake.nix`** defines:
   - `system` and `username` variables (shared across all hosts)
   - Inputs: nixpkgs, nixpkgs-pinned, home-manager, nix-flatpak, nvf,
     plasma-manager
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
   - `variables.nix` contains all customization options (git config, app
     toggles, feature flags)
   - `hardware.nix` contains hardware-specific configuration (generated by
     nixos-generate-config)
   - `default.nix` imports hardware config and optionally `host-packages.nix`
   - `host-packages.nix` (optional) - Host-specific packages not suitable for
     variables.nix toggles

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
   - Terminal emulator (ghostty) is directly imported
   - Editors (vscode, nvf) are directly imported
   - Core modules (git, zsh, scripts, cli-tools) are always imported
   - No conditional imports - all modules are active

### Variables System

All host-specific customization happens through
`hosts/{hostname}/variables.nix`. The variables file is now minimal and focused
on essential settings:

**Personal Settings:**

- `gitUsername` - Git user name (email is stored in encrypted secret)

**System Settings:**

- `keyboardLayout` - Keyboard layout (e.g., "us,ru" for US + Russian)
- `consoleKeyMap` - Console keyboard mapping
- `printEnable` - Enable printing support (true/false)
- `sshKeyPath` - Path to SSH private key for agenix secrets decryption

**Sensitive Data:**

Sensitive information is stored in encrypted secrets managed by agenix:

- `secrets/work-email.age` - Work email address for git commits
- `secrets/ssh-*` - SSH host IPs, hostnames, and usernames

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

    # CLI tools
    ./cli-tools/bat.nix
    ./cli-tools/eza.nix
    ./cli-tools/fzf.nix
    # ... and more
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

- KDE Plasma 6 desktop environment
- SDDM display manager
- X11 server enabled (required for Plasma)
- Full KDE application suite (Dolphin, Konsole, Kate, Spectacle, etc.)

**System Features:**

- Desktop applications (browsers, terminals, IDEs)
- Theming and appearance (GTK, Qt)
- GUI system tools (Flatpak, fonts, Steam)
- Virtualization support (libvirt/QEMU)
- Optional printing support (controlled via `printEnable`)

**CLI Environment:**

- Full CLI toolset: bat, btop, eza, fzf, lazygit, zoxide
- Neovim with nvf configuration
- Ghostty terminal emulator
- Git, SSH, and ZSH configuration
- Custom scripts including `dot` management tool

Note: This configuration does not currently support server-only deployments. All
modules are oriented toward desktop/laptop use.

### KDE Plasma 6 Configuration

The system uses KDE Plasma 6 as the desktop environment with the following
configuration:

- **`modules/core/desktop/environments/plasma.nix`** - System-level Plasma 6
  configuration
  - Enables KDE Plasma 6 desktop environment
  - Configures core Plasma packages (plasma-desktop, plasma-workspace)
  - Installs KDE applications (Dolphin, Konsole, Kate, Ark, Okular, Gwenview,
    Spectacle)
  - Sets up system integration (plasma-pa, plasma-nm, kscreen, bluedevil,
    powerdevil)
  - Configures KWallet PAM integration for automatic wallet unlocking

- **`modules/core/desktop/display-managers/sddm.nix`** - SDDM display manager
  configuration
  - Manages login screen and session selection
  - Wayland support enabled by default

- **`modules/core/desktop/environments/xserver.nix`** - X11 server configuration
  - Required for Plasma 6 functionality
  - Configured with keyboard layouts from `variables.nix`

Future declarative Plasma configuration may use plasma-manager (currently added
as a flake input but not yet configured).

### GPU Profile System

GPU profiles are defined in `profiles/` and each host specifies its profile in
`flake.nix`. Each profile:

- Has a corresponding directory in `profiles/{profile}/` with a `default.nix`
- Enables specific GPU drivers from `modules/drivers/`
- Is specified per-host in the `nixosConfigurations` section

**Currently available profiles:**

- **amd** - AMD GPU drivers
- **intel** - Intel integrated graphics
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
   - Prompts for system type (laptop/desktop or server)
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
   - Prompts for system type (laptop/desktop or server)
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

KDE Plasma configuration is currently done through the GUI System Settings
application:

- **Appearance**: Themes, colors, icons, fonts
- **Workspace Behavior**: Window management, activities, virtual desktops
- **Shortcuts**: Keyboard shortcuts and global hotkeys
- **Applications**: Default applications, file associations
- **Input Devices**: Keyboard, mouse, touchpad settings

Future versions may use plasma-manager for declarative configuration. The
plasma-manager flake input is already added but not yet configured.

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
   - Run `dot update-host` to sync hostname with flake.nix

2. **Review variables.nix**: Ensure all enabled apps have corresponding modules
   - If `{app}Enable = true`, the module file must exist in `modules/home/`

3. **Check for syntax errors**: Run `nix flake check` for detailed error
   messages

4. **Review recent changes**: Use `git diff` to see what changed since last
   successful rebuild

5. **Rollback if needed**: Previous generations are available in the boot menu

### Common Issues

- **"hostname mismatch" error**: `dot` verifies hostname before rebuild. Run
  `dot update-host` or manually edit `flake.nix`
- **Missing module error**: An enabled app in `variables.nix` has no
  corresponding module file
- **Home-manager backup files**: Automatically cleaned by `dot` rebuild process
- **Failed flake check**: Often indicates missing imports or syntax errors in
  `.nix` files

## Adding New Features

### Adding a New Application Module

1. Create a new module file in `modules/home/{app}.nix` or
   `modules/core/{app}.nix`
2. Add a corresponding `{app}Enable` variable to
   `hosts/{hostname}/variables.nix`
3. Add conditional import to `modules/home/default.nix` or unconditional import
   to `modules/core/default.nix`
4. Run `nix flake check` to validate syntax
5. Run `dot rebuild` to build and test

**Example home module** (`modules/home/myapp.nix`):

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    myapp
  ];
}
```

### Adding a New GPU Profile

1. Create `profiles/{profile}/default.nix` with imports structure
2. Create driver module in `modules/drivers/{driver}-drivers.nix` with enable
   option
3. Enable the driver in the profile: `drivers.{driver}.enable = true`
4. Add `nixosConfiguration.{profile} = mkNixosConfig "{profile}"` to `flake.nix`
5. Update `dot update-host` GPU detection logic in
   `modules/home/scripts/dot.nix`

## Important Conventions

1. **KDE Plasma 6** - This configuration uses KDE Plasma 6 as the desktop
   environment
2. **No Stylix** - Stylix theming system has been removed; theming is done
   through KDE System Settings
3. **Unconditional imports** - All modules are imported unconditionally; there
   are no `{app}Enable` toggles
4. **Host-specific settings** - Minimal customization in
   `hosts/{hostname}/variables.nix` (git config, keyboard, print)
5. **GPU profiles** - Match the profile to hardware or use `dot update-host`
   auto-detection
6. **Backup cleanup** - Home-manager backup files are automatically cleaned by
   `dot rebuild`
7. **Terminal** - Ghostty is the configured terminal emulator (replaced Kitty)
8. **Module organization** - System-level config in `modules/core/`, user config
   in `modules/home/`
9. **Variables pattern** - Only minimal variables are used; import with
   `inherit (import ../../hosts/${host}/variables.nix)`
10. **Pre-commit validation** - ALWAYS run `nix flake check` before creating any
    git commit to ensure configuration validity
11. **Git commit messages** - Do not include "Generated with Claude Code" or
    "Co-Authored-By: Claude" signatures in commit messages

- search packages using nh search
