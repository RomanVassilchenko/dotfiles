{ pkgs, ... }:
let
  git-ai-commit = pkgs.writeShellScriptBin "git-ai-commit" ''
        set -e

       if ! git diff --cached --quiet; then
          diff=$(git diff --cached)
        else
          echo "No staged changes. Stage changes first with 'git add'"
          exit 1
        fi

        echo "Select AI tool:"
        echo "  1) claude"
        echo "  2) codex (default)"
        echo "  3) gemini"
        echo "  4) opencode"
        echo ""
        printf "Choice [1-4]: "
        read -r choice

        recent_commits=$(git log --oneline -10 2>/dev/null || echo "")

        prompt="Generate a git commit message for this diff. Output ONLY the commit message - no meta-commentary.

        Follow the style of recent commits in this repo:
        $recent_commits

        Rules:
        - Match the prefix style (feat/fix/refactor/docs/style/test/chore, etc.)
        - First line under 72 chars
        - Optional body after blank line explaining why
        - No AI attribution or quotes"

        echo ""
        echo "Generating commit message..."

        case "$choice" in
          1|claude)
            msg=$(echo "$diff" | ${pkgs.llm-agents.claude-code}/bin/claude -p \
              --allowedTools "" \
              --output-format text \
              "$prompt")
            ;;
          3|gemini)
            msg=$(echo "$diff" | ${pkgs.llm-agents.gemini-cli}/bin/gemini "$prompt")
            ;;
          4|opencode)
            msg=$(echo "$diff" | ${pkgs.llm-agents.opencode}/bin/opencode "$prompt")
            ;;
          2|codex|*)
            tmpfile=$(mktemp)
            ${pkgs.llm-agents.codex}/bin/codex exec -o "$tmpfile" "$prompt

    $diff" >/dev/null 2>&1
            msg=$(cat "$tmpfile")
            rm -f "$tmpfile"
            ;;
        esac

        echo ""
        echo "Proposed commit message:"
        echo "────────────────────────"
        echo "$msg"
        echo "────────────────────────"
        echo ""

        printf "Commit with this message? [Y/n] "
        read -r answer

        if [ "$answer" != "n" ] && [ "$answer" != "N" ]; then
          git commit -m "$msg"
          echo "Committed!"
        else
          echo "Aborted."
        fi
  '';
in
{
  home.packages = [ git-ai-commit ];
}
