# CLAUDE.md

Rules and guidelines for Claude Code when working with this repository.

## Essential Commands

```bash
# Validate before committing (MANDATORY)
nix flake check

# Rebuild system
dot rebuild

# Search for packages
nh search <package>
```

## Rules

1. **Always validate before committing**: Run `nix flake check` before every
   `git commit`
2. **No Claude signatures**: Do not include "Generated with Claude Code" or
   "Co-Authored-By: Claude" in commit messages
3. **Read before modifying**: Never propose changes to code you haven't read
4. **Keep it simple**: Avoid over-engineering; make only necessary changes
5. **Use existing patterns**: Follow the module patterns already in the codebase

## Project Structure

- `flake.nix` - Main entry point with `mkNixosConfig` helper
- `hosts/{hostname}/` - Host-specific configs (`variables.nix`, `hardware.nix`)
- `modules/core/` - System-level NixOS modules
- `modules/home/` - Home-manager user modules
- `modules/drivers/` - GPU driver configurations
- `profiles/` - GPU profile configurations (amd, intel, nvidia, etc.)
- `secrets/` - Agenix encrypted secrets

## Key Patterns

### Adding Packages

- Host-specific: `hosts/{hostname}/host-packages.nix`
- System-wide: `modules/core/packages/`
- User packages: `modules/home/cli-tools/` or relevant category

### Module Structure

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [ package-name ];
}
```

### Conditional Imports (deviceType)

```nix
imports = [ ... ] ++ lib.optionals (!isServer) [ ./desktop-module.nix ];
```

- `deviceType = "laptop"` - Full desktop with KDE Plasma 6
- `deviceType = "server"` - CLI only, no GUI

### Variables

Host customization in `hosts/{hostname}/variables.nix`:

- `gitUsername`, `keyboardLayout`, `consoleKeyMap`
- `printEnable`, `workEnable`, `sshKeyPath`, `deviceType`

## Common Tasks

| Task               | Command/Location                                             |
| ------------------ | ------------------------------------------------------------ |
| Add user package   | Create module in `modules/home/cli-tools/`                   |
| Add system package | Edit `modules/core/packages/`                                |
| Add autostart app  | Edit `modules/home/desktop/kde/autostart.nix`                |
| Add secret         | Edit `secrets/secrets.nix`, run `agenix -e secrets/name.age` |
| Add new host       | Run `dot add-host hostname [profile]`                        |

## Current Hosts

| Hostname    | Type   | GPU   | Hardware                      |
| ----------- | ------ | ----- | ----------------------------- |
| laptop-82sn | laptop | amd   | AMD Ryzen 6800H + Radeon 680M |
| probook-450 | laptop | intel | Intel integrated graphics     |
