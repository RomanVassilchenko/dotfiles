# Stow-managed Dotfiles

This directory contains dotfiles managed with GNU Stow for easy symlinking to
your home directory.

## Structure

Each subdirectory represents a "package" that can be stowed independently:

- `ssh/` - SSH configuration and keys
- `camunda/` - Camunda Modeler dark theme plugin

## Usage

The `.stowrc` file in the dotfiles root is configured to automatically use the
correct paths.

### Installing/Linking a Package

From the dotfiles root directory:

```bash
stow ssh
```

This will create symlinks from `~/` to the files in `stow/ssh/`.

### Unlinking a Package

```bash
stow -D ssh
```

### Re-stowing (useful after updates)

```bash
stow -R ssh
```

### Stowing All Packages

```bash
stow */
```

## SSH Package

The SSH package contains:

- Private SSH keys (gitignored, not tracked in git)
- Public SSH keys (tracked in git)
- `known_hosts` file (gitignored)

**Note**: The SSH config file is managed by NixOS home-manager in
`modules/home/ssh.nix`, not by stow.

### Setting up SSH on a new machine

1. Clone this repository
2. Run `stow ssh` to create symlinks
3. Set proper permissions: `chmod 600 ~/.ssh/id_*`
4. Rebuild NixOS to apply the SSH config: `dot rebuild`

## Adding New Packages

To add a new dotfile package:

1. Create a new directory: `mkdir stow/packagename`
2. Create the directory structure mirroring your home directory:
   `mkdir -p stow/packagename/.config/app`
3. Copy or move your dotfiles:
   `cp ~/.config/app/config stow/packagename/.config/app/`
4. Update `.gitignore` if needed to exclude sensitive files
5. Stow it: `stow packagename`

## .gitignore Rules

Private SSH keys are excluded from git tracking:

- All `id_*` files (private keys) are ignored
- `*.pub` files (public keys) are tracked
- `known_hosts` is ignored
