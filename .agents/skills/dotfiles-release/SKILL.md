---
name: dotfiles-release
description: Commit and push a dotfiles repository private-first, then public, then rebuild. Use inside this repository or compatible forks.
---

# Skill: dotfiles-release

Use this skill only when the user explicitly asks to release, commit, push, and/or rebuild a NixOS dotfiles repository.

## Purpose

This skill performs a safe release workflow for this repository or a compatible fork:

1. Detect the public repository root from the current working tree.
2. Check the optional `private/` submodule or nested repository if it exists.
3. Commit and push private changes first, if there are any.
4. Commit and push public changes, if there are any.
5. Rebuild the current NixOS host.

## Scope

- Work only inside the detected repository root and its optional `private/` directory.
- Do not assume a specific username, hostname, remote name, local path, or private infrastructure.
- Prefer the current branch and its configured upstream.
- If there is no configured upstream, stop and ask before pushing.
- If `private/` does not exist or is not a Git repository, skip private release steps.

## Safety Rules

- Never run the workflow silently. The user must explicitly request release, commit, push, or rebuild.
- Commit all relevant tracked, modified, deleted, and untracked files, except ignored files.
- Never add ignored files with `git add -f`.
- Never read or reveal secret contents, keys, `.env`, raw private config, authentication files, or session files.
- Never include private file contents in responses, diff snippets, or commit messages.
- Do not use `--no-verify`, `--force`, `push --force`, destructive resets, or commit amend.
- Do not create empty commits.
- Write commit messages in Conventional Commit format without mentioning AI assistance.

## Preflight Checks

Run these checks in the public repository root:

```bash
git status --short --ignored=matching
git diff --stat
git diff --cached --stat
git remote -v
git branch --show-current
git status --short --branch
```

If `private/` is a Git repository, run the same status and diff-stat checks there.

Before committing public changes, check for accidentally tracked sensitive paths:

```bash
git grep -n -E '(^|/)(id_[^/]*|.*\.age|\.env|secrets?|credentials?|auth|session|token|config/ssh|\.config/git/secrets)(/|$)' -- ':!private' ':!.git'
```

If this check finds suspicious public material, stop and either fix `.gitignore`, remove the material from the public repo, or ask the user.

## Private Commit

Only run this section when `private/` exists and is a Git repository.

1. Check private repo status with `git status --short --ignored=matching`.
2. If there are no non-ignored changes, skip private commit and push.
3. Stage all private changes with `git add -A`.
4. Create a Conventional Commit message based on the change type.
5. Commit with `git commit -m "<message>"`.
6. Push to the current branch upstream with `git push`.

Recommended private commit messages:

- `chore: update private dotfiles state` for mixed private updates.
- `fix: ...` only for a clear behavior fix.
- `feat: ...` only for new private functionality.

## Public Commit

1. Check public repo status with `git status --short --ignored=matching`.
2. If there are no non-ignored public changes, skip public commit and push.
3. Stage all public changes with `git add -A`.
4. If private was committed and `private/` is a submodule, ensure the submodule pointer is staged.
5. Create a Conventional Commit message based on the change type.
6. Commit with `git commit -m "<message>"`.
7. Push to the current branch upstream with `git push`.

Recommended public commit messages:

- `chore: update dotfiles release` for mixed Nix/config changes.
- `feat: add ...` for new modules, packages, hosts, docs, or skills.
- `refactor: ...` for structural changes without new behavior.
- `fix: ...` for configuration or behavior fixes.
- `docs: ...` for documentation-only changes.

## Rebuild

After a successful public push, rebuild the current system.

Preferred command when the repository provides the helper CLI:

```bash
dot rebuild --plain
```

Fallback command when `dot` is unavailable:

```bash
sudo nixos-rebuild switch --flake .#$(hostname)
```

If rebuild fails:

1. Diagnose the failure without exposing secrets.
2. Make the smallest correct fix.
3. Repeat the private/public commit and push workflow only for the new fix.
4. Run the rebuild again.

## Final Response

Report briefly:

- Private commit hash, or that there were no private changes.
- Public commit hash, or that there were no public changes.
- Push result.
- Rebuild result.
- Any residual warning that still needs user attention.
