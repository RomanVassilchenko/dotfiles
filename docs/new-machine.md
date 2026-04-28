# New Machine Guide

This guide assumes the machine already has a working NixOS installation and you can copy hardware data from `/etc/nixos/hardware-configuration.nix`.

That means the flow is:

1. Install NixOS once in the normal way.
2. Boot into the installed system.
3. Clone this repo.
4. Create a host from the public template.
5. Copy the generated hardware file.
6. Rebuild against your new host.

## 1. Clone The Repo

```bash
git clone https://github.com/RomanVassilchenko/dotfiles ~/Documents/dotfiles
cd ~/Documents/dotfiles
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

- `hosts/$HOSTNAME/facts.nix`
- `hosts/$HOSTNAME/default.nix`
- `hosts/$HOSTNAME/hardware.nix`

## 3. Copy Hardware Configuration

Replace the template hardware file with the real one from the installed system:

```bash
cp /etc/nixos/hardware-configuration.nix "hosts/$HOSTNAME/hardware.nix"
```

That file is the machine-specific hardware baseline. Keep it per-host.

## 4. Fill In `facts.nix`

Edit `hosts/$HOSTNAME/facts.nix`.

Example for a personal laptop:

```nix
{
  username = "alice";
  gitUsername = "Alice Example";
  gitEmail = "alice@example.com";

  system = "x86_64-linux";
  profile = "workstation";
  gpuProfile = "amd";
  deviceType = "laptop";

  keyboardLayout = "us";
  consoleKeyMap = "us";
  timeZone = "Europe/Berlin";
  defaultLocale = "en_US.UTF-8";

  authorizedKeys = [
    "ssh-ed25519 AAAA... alice@example.com"
  ];
}
```

Meaning of the important fields:

- `username`: primary Linux user managed by the config
- `gitUsername`: display name for Git config and user metadata
- `gitEmail`: Git commit email
- `system`: target platform, usually `x86_64-linux`
- `profile`: high-level label, currently `workstation` or `server`
- `gpuProfile`: currently `intel` or `amd`
- `deviceType`: `laptop` or `server`
- `authorizedKeys`: SSH public keys for the main user account

`dotfilesPath` is optional. If omitted, it defaults to `~/Documents/dotfiles` for that user.

## 5. Choose Feature Bundles In `default.nix`

Edit `hosts/$HOSTNAME/default.nix` to match the machine.

Example workstation:

```nix
{ ... }:
{
  imports = [
    ./hardware.nix
  ];

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
{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  features = {
    stylix.enable = true;
  };
}
```

For a server, make sure `facts.nix` uses:

```nix
profile = "server";
deviceType = "server";
```

## 6. Register The Host

Open `parts/nixos.nix` and add the hostname to `hostNames`.

Example:

```nix
  hostNames = [
    "laptop-82sn"
    "ninkear"
    "my-laptop"
  ];
```

This repository currently uses an explicit host list.

## 7. First Rebuild

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

- If `username` matches your existing installed user, Home Manager and user settings will attach to that account.
- If `username` is new, NixOS will create that user account on rebuild.
- Passwords are not declared in this repo, so a newly created user may still need `passwd` after the first activation.

## Notes About Private Configuration

The public repo does not require `private/`.

If you later add a private overlay, it can provide:

- agenix secrets
- work-only services
- private Git and SSH config
- personal infrastructure modules

## Recommended Workflow

For public reuse, treat these hosts as separate roles:

- `hosts/template`: your reusable starting point
- `hosts/laptop-82sn`: author's personal laptop
- `hosts/ninkear`: author's personal server

That keeps the public onboarding clean while preserving personal machines in the same flake.
