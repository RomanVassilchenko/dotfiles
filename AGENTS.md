# Dotfiles Agent Instructions

Project-specific guidance for OpenCode and compatible coding agents in this repository.

## Scope

This file is only for `/home/romanv/Documents/dotfiles`. Do not carry `dot` commands, host names, NixOS rebuild workflows, or service details into other projects.

Global OpenCode behavior belongs in `config/opencode/opencode.json`. Dotfiles-only permissions and instructions belong in the root `opencode.json` project config.

## Repository

Modular NixOS dotfiles for multiple machines. Uses Nix Flakes, home-manager, agenix, and a private submodule for secrets/work-only configuration.

Primary development device: `laptop-82sn`.

## Commands

```bash
dot rebuild --plain      # rebuild current system through the dot wrapper
dot rebuild --dry        # preview rebuild changes
dot rebuild-boot         # rebuild, activate on next boot
dot update               # update flake inputs and rebuild
dot doctor               # health checks
nix eval *               # inspect options/values
nix flake check --no-build
```

Use `dot rebuild --dry` or `nix flake check --no-build` before applying system changes when practical. Commands that rebuild, update, back up, or touch external systems should require confirmation.

## Architecture

- `flake.nix` defines hosts via `mkNixosConfig` and passes `host`, `vars`, `isServer`, and `profile` to modules.
- `hosts/` contains per-machine hardware, variables, shared defaults, and profiles.
- `modules/core/` contains system-level modules.
- `modules/home/` contains home-manager user configuration.
- `modules/drivers/` contains GPU driver modules.
- `private/` is a private submodule for secrets, work VPN, and work git config.
- `config/` contains external app/agent configs symlinked by home-manager.

## NixOS Rules

- Use `nixos-best-practices` before changing flakes, overlays, host profiles, or home-manager wiring.
- Follow existing module patterns before introducing new structure.
- Do not guess option names; verify with existing code, docs, or `nix eval`.
- With `home-manager.useGlobalPkgs = true`, define overlays at the NixOS/home-manager integration layer, not inside arbitrary home modules.

## Secrets

Secrets live in `private/secrets/` and are managed with agenix. Do not read or modify secret material unless explicitly requested.

Access secrets from Nix through `config.age.secrets.<name>.path`.

## Git

Use Conventional Commits when the user asks for a commit. Do not include AI-generated footers or co-author lines.

## Skills

- `nixos-best-practices` for NixOS/home-manager/flake work.
- `dotfiles-release` for the private-first/public release workflow.
- `find-skills` when a new reusable workflow would otherwise bloat these instructions.
