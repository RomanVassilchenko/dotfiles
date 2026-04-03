{ pkgs, ... }:
{
  home.file.".config/git/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Auto-format staged files before commit

      # Get the root of the git repository
      ROOT=$(git rev-parse --show-toplevel)

      # Check if we're in the dotfiles repository
      if [[ "$ROOT" == *"dotfiles"* ]]; then
        # Format staged .nix files
        STAGED_NIX=$(git diff --cached --name-only --diff-filter=ACM | grep '\.nix$' || true)
        if [[ -n "$STAGED_NIX" ]]; then
          echo "Formatting Nix files..."
          echo "$STAGED_NIX" | while read -r file; do
            if [[ -f "$file" ]]; then
              ${pkgs.nixfmt}/bin/nixfmt "$file"
              git add "$file"
            fi
          done
        fi

        # Format staged .sh files
        STAGED_SH=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)
        if [[ -n "$STAGED_SH" ]]; then
          echo "Formatting Shell files..."
          echo "$STAGED_SH" | while read -r file; do
            if [[ -f "$file" ]]; then
              ${pkgs.shfmt}/bin/shfmt -w -i 2 -ci "$file"
              git add "$file"
            fi
          done
        fi

        # Format staged .md files
        STAGED_MD=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)
        if [[ -n "$STAGED_MD" ]]; then
          echo "Formatting Markdown files..."
          echo "$STAGED_MD" | while read -r file; do
            if [[ -f "$file" ]]; then
              ${pkgs.prettier}/bin/prettier --write "$file"
              git add "$file"
            fi
          done
        fi
      fi

      exit 0
    '';
  };

  programs.git.settings = {
    core.hooksPath = "~/.config/git/hooks";
  };
}
