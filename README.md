<div align="center">

# NixOS Dotfiles

[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-7EBAE4?style=flat-square&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-6F86D6?style=flat-square)](https://github.com/nix-community/home-manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](./LICENSE)

Modular NixOS configuration with typed host metadata, reusable feature bundles, Home Manager, and an optional private overlay.

<p align="center">
  <img src=".github/fastfetch.png" alt="Fastfetch system overview" width="49%" />
  <img src=".github/onefetch.png" alt="Onefetch repository overview" width="49%" />
</p>

</div>

## Overview

This repository is split into two layers:

- A reusable public base for machines, users, feature bundles, and app toggles
- An optional `private/` submodule for secrets, work-only services, and personal infrastructure

The public part builds without `private/`.

## Start Here

- New machine or new user: follow [`docs/new-machine.md`](docs/new-machine.md)
- Feature bundle model: see [`docs/features.md`](docs/features.md)
- Private-first release flow: see [`docs/release.md`](docs/release.md)
- Existing configured host: `sudo nixos-rebuild switch --flake .#$(hostname)`
- Optional CLI install: `nix profile install .#dot`

## Host Model

Public machine roles live in `hosts/<hostname>/` and define reusable metadata,
feature bundles, and non-secret defaults:

- `default.nix`: typed `dotfiles.*` metadata plus feature bundles and machine-specific overrides

New public hosts should start from `hosts/template/`. Hardware configuration and
personal identity overrides should live in `private/hosts/<hostname>/`.

## Quick New-Host Flow

```bash
HOSTNAME="my-laptop"

git clone https://github.com/<owner>/dotfiles ~/dotfiles
cd ~/dotfiles

cp -r hosts/template "hosts/$HOSTNAME"
cp /etc/nixos/hardware-configuration.nix "hosts/$HOSTNAME/hardware.nix"

# Edit hosts/$HOSTNAME/default.nix

sudo nixos-rebuild switch --flake ".#$HOSTNAME"
```

Detailed guide: [`docs/new-machine.md`](docs/new-machine.md)

## Feature Bundles

Host `default.nix` files enable high-level bundles under `features.*`.

Available bundles in the public repo:

- `development`: developer tooling
- `desktop`: base graphical desktop support
- `kde`: KDE Plasma desktop session
- `productivity`: productivity defaults such as Bitwarden
- `communication`: communication apps such as Telegram, Discord, and ZapZap
- `printing`: print support
- `stylix`: system-wide theming
- `work`: work-specific integrations if your private overlay provides them

App-level overrides live under `features.apps.*`. Current public app toggles include:

- `bitwarden`
- `discord`
- `obsStudio`
- `telegram`
- `zapzap`

Example:

```nix
{
  features = {
    development.enable = true;
    kde.enable = true;
    productivity.enable = true;

    apps = {
      telegram = {
        enable = true;
        autostart = true;
      };
    };
  };
}
```

## Repository Layout

```text
.
├── flake.nix
├── parts/nixos.nix         # Host registry and NixOS assembly
├── hosts/
│   ├── default/common.nix  # Generic shared defaults
│   ├── template/           # Starting point for new machines
│   └── <hostname>/         # Public host role defaults
├── features/               # Public feature bundles and app toggles
├── modules/core/           # System modules
├── modules/home/           # Home Manager modules
├── modules/drivers/        # GPU driver modules
├── config/                 # App/editor configs symlinked into $HOME
└── private/                # Optional secrets and personal/work overlay
```

## `dot` CLI

The repo exposes a `dot` CLI as a flake package.

```bash
nix profile install .#dot

dot rebuild --plain
dot rebuild --dry
dot rebuild-boot
dot update
dot check
dot cleanup
```

Server-specific commands such as backup and remote rebuilds depend on private configuration.

## AI-Assisted Workflow

This repository is organized so AI coding agents can help with day-to-day NixOS work without needing private secrets.

- Use agents to inspect modules, explain host wiring, suggest feature splits, and draft safe Nix changes.
- Keep secrets in `private/` or another ignored location, and do not paste secret values into prompts.
- Ask agents to run `nix eval`, `nix flake check --no-build`, or `dot rebuild --plain` after changes when practical.
- Treat generated changes like normal code review: inspect diffs, keep commits focused, and verify before rebuilding important machines.

Repo-local agent resources live under `.agents/` when present. They are optional helpers, not required to build the system.

## Public vs Private

`private/` is optional and is auto-imported only when present.

Typical `private/` content:

- agenix secrets
- work VPN and work Git configuration
- self-hosted services and infrastructure integration
- machine-specific hardware and identity overrides

If you only want the public configuration, skip `private/` entirely.

---

<p align="center">
  <a href="https://github.com/catppuccin/catppuccin">
    <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
  </a>
</p>
