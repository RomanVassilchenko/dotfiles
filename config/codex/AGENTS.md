# Codex User Instructions

Use the repository's own `AGENTS.md` first when present. Treat these instructions as user-level defaults for projects without stronger local guidance.

- Be pragmatic and make the smallest correct change.
- Inspect the project before editing; do not guess package names, commands, or config keys.
- Preserve user changes in a dirty worktree. Never revert unrelated edits unless explicitly asked.
- Prefer targeted verification after non-trivial changes: tests, build, lint, dry-run, or a clear command that proves the change.
- Do not add AI attribution, co-author trailers, or generated-by footers to commits or files.
- Keep credentials, tokens, `.env` files, and private key material out of commits and summaries.
- For NixOS or Home Manager changes, verify option names and follow the existing module structure.
