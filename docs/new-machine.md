# New Machine Guide

This guide assumes the machine already has a working NixOS installation and you can copy hardware data from `/etc/nixos/hardware-configuration.nix`.

That means the flow is:

1. Install NixOS once in the normal way.
2. Boot into the installed system.
3. Clone this repo.
4. Create a host from the public template.
5. Copy the generated hardware file.
6. Fill in `default.nix`.
7. Validate the new host.
8. Rebuild against your new host.

## 1. Clone The Repo

```bash
git clone https://github.com/RomanVassilchenko/dotfiles ~/dotfiles
cd ~/dotfiles
```

The public repo works without `private/`.

## 2. Create A Host Directory

Pick the machine hostname first:

```bash
hostnamectl set-hostname my-laptop
HOSTNAME="my-laptop"
```

Create a new host from the generic template:

```bash
cp -r hosts/template "hosts/$HOSTNAME"
```

This gives you:

- `hosts/$HOSTNAME/default.nix`
- `hosts/$HOSTNAME/hardware.nix`

## 3. Copy Hardware Configuration

Replace the template hardware file with the real one from the installed system:

```bash
cp /etc/nixos/hardware-configuration.nix "hosts/$HOSTNAME/hardware.nix"
```

That file is the machine-specific hardware baseline. Keep it per-host.

## 4. Fill In `default.nix`

Edit `hosts/$HOSTNAME/default.nix`.

The host file now carries both typed machine metadata under `dotfiles.*` and feature flags under `features.*`.

Example workstation:

```nix
{
  imports = [
    ./hardware.nix
  ];

  dotfiles = {
    host = {
      profile = "workstation";
      system = "x86_64-linux";
      gpuProfile = "amd";
      deviceType = "laptop";
    };

    user = {
      name = "jane";
      gitName = "Jane Doe";
      gitEmail = "jane@example.com";
      authorizedKeys = [
        "ssh-ed25519 AAAA... jane@example.com"
      ];
    };

    locale = {
      keyboardLayout = "us";
      consoleKeyMap = "us";
      timeZone = "Europe/Berlin";
      defaultLocale = "en_US.UTF-8";
    };
  };

  features = {
    development.enable = true;
    kde.enable = true;
    productivity.enable = true;
    stylix.enable = true;

    apps = {
      telegram = {
        enable = true;
        autostart = true;
      };
      virtManager.enable = true;
    };
  };
}
```

Example headless server:

```nix
{
  imports = [
    ./hardware.nix
  ];

  dotfiles = {
    host = {
      profile = "server";
      system = "x86_64-linux";
      gpuProfile = "amd";
      deviceType = "server";
    };

    user = {
      name = "jane";
      gitName = "Jane Doe";
      gitEmail = "jane@example.com";
      authorizedKeys = [
        "ssh-ed25519 AAAA... jane@example.com"
      ];
    };

    locale = {
      keyboardLayout = "us";
      consoleKeyMap = "us";
      timeZone = "Europe/Berlin";
      defaultLocale = "en_US.UTF-8";
    };
  };

  features.stylix.enable = true;
}
```

Meaning of the important `dotfiles` fields:

- `dotfiles.host.profile`: high-level role, currently `workstation` or `server`
- `dotfiles.host.system`: target platform, usually `x86_64-linux`
- `dotfiles.host.gpuProfile`: currently `intel` or `amd`
- `dotfiles.host.deviceType`: currently `laptop` or `server`
- `dotfiles.user.name`: primary Linux user managed by the config
- `dotfiles.user.gitName`: display name for Git config and user metadata
- `dotfiles.user.gitEmail`: default Git commit email
- `dotfiles.user.authorizedKeys`: SSH public keys for the main user account
- `dotfiles.locale.*`: keyboard, console and locale settings

`dotfiles.paths.dotfiles` is optional. If omitted, it defaults to `~/dotfiles` for that user.

## 5. Validate The Host

Because host directories are auto-discovered, there is no separate registration step anymore. If `hosts/$HOSTNAME/default.nix` exists, the flake will pick it up automatically.

Run:

```bash
nix flake check --no-build
```

Or, if the helper CLI is already installed:

```bash
dot validate full
```

## 6. First Rebuild

Run:

```bash
sudo nixos-rebuild switch --flake ".#$HOSTNAME"
```

Or install the helper CLI and use:

```bash
nix profile install .#dot
dot rebuild --plain
```

## Notes About Users

- If `dotfiles.user.name` matches your existing installed user, Home Manager and user settings will attach to that account.
- If `dotfiles.user.name` is new, NixOS will create that user account on rebuild.
- Passwords are not declared in this repo, so a newly created user may still need `passwd` after the first activation.

## Notes About Private Configuration

The public repo does not require `private/`.

If you later add a private overlay, it can provide:

- agenix secrets
- work-only services
- private Git and SSH config
- personal infrastructure modules

That private layer is additive. Get the public host bootstrapped first, then initialize `private/` and re-run validation.

## Recommended Workflow

For public reuse, treat these hosts as separate roles:

- `hosts/template`: reusable starting point
- `hosts/laptop-82sn`: author's personal laptop
- `hosts/ninkear`: author's personal server

That keeps the public onboarding clean while preserving personal machines in the same flake.
