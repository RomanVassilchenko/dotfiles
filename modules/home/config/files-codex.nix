{
  config,
  dotfiles,
  ...
}:
let
  shared = import ./files-shared.nix { inherit config dotfiles; };
in
{
  home.file = {
    ".codex/AGENTS.md".text = ''
      # Codex User Instructions

      @~/.codex/RTK.md

      Use the repository's own `AGENTS.md` first when present. Treat these instructions as user-level defaults for projects without stronger local guidance.

      - Be pragmatic and make the smallest correct change.
      - Inspect the project before editing; do not guess package names, commands, or config keys.
      - Preserve user changes in a dirty worktree. Never revert unrelated edits unless explicitly asked.
      - Prefer targeted verification after non-trivial changes: tests, build, lint, dry-run, or a clear command that proves the change.
      - Do not add AI attribution, co-author trailers, or generated-by footers to commits or files.
      - Keep credentials, tokens, `.env` files, and private key material out of commits and summaries.
      - For NixOS or Home Manager changes, verify option names and follow the existing module structure.
    '';

    ".codex/config.toml".source = shared.outOfStore "${shared.privateConfig}/codex/config.toml";

    ".codex/RTK.md".text = ''
      # RTK - Rust Token Killer (Codex CLI)

      Use `rtk` for shell commands when practical so Codex receives compact command output.

      Examples:

      ```bash
      rtk git status
      rtk git diff
      rtk rg "pattern" .
      rtk nix flake check --no-build
      ```

      Use raw commands when exact output matters or when `rtk` does not support the command well.

      Useful RTK commands:

      ```bash
      rtk gain
      rtk gain --history
      rtk proxy <cmd>
      ```
    '';
  };
}
