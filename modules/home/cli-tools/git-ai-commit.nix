{ pkgs, ... }:
let
  git-ai-commit = pkgs.writeShellScriptBin "git-ai-commit" ''
    set -euo pipefail

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "Not inside a git work tree"
      exit 1
    fi

    if git diff --cached --quiet --exit-code; then
      echo "No staged changes to commit"
      echo "Stage changes with git add first."
      exit 1
    fi

    status=$(git status --short --untracked-files=all)

    context_file=$(mktemp -t git-ai-context.XXXXXX)
    raw_message_file=$(mktemp -t git-ai-message-raw.XXXXXX)
    message_file=$(mktemp -t git-ai-message.XXXXXX)
    trap 'rm -f "$context_file" "$raw_message_file" "$message_file"' EXIT

    {
      printf 'Recent commits (latest 20):\n'
      git log --oneline -20 2>/dev/null || true
      printf '\nStaged files (name-status):\n'
      git diff --cached --name-status --find-renames
      printf '\nStaged diff summary:\n'
      git diff --cached --summary
      printf '\nStaged diff stat:\n'
      git diff --cached --stat --find-renames
      printf '\nFull working tree status (ignore unstaged and untracked entries):\n'
      printf '%s\n' "$status"
    } >"$context_file"

    prompt="Generate a git commit message for ONLY the staged changes described in the attached git context file.

    Output ONLY the commit message. Do not use markdown, code fences, quotes, explanations, or AI attribution.

    Rules:
    - Follow the style and structure of the latest 20 commits in the context.
    - Prefer the repo's Conventional Commit style when it fits.
    - Use an optional scope only when it is clear from the changed files.
    - Keep the first line under 72 characters.
    - Add a body only when it explains useful why/context.
    - Ignore unstaged and untracked files from the working tree status.
    - Do not inspect files or run commands; the attached context is enough."

    echo "Generating commit message with opencode..."
    if ! ${pkgs.llm-agents.opencode}/bin/opencode run \
      --pure \
      --title "git ai commit message" \
      --file "$context_file" \
      "$prompt" >"$raw_message_file"; then
      echo "opencode failed to generate a commit message"
      exit 1
    fi

    awk '
      /^```/ { next }
      {
        sub(/\r$/, "")
        lines[++n] = $0
      }
      END {
        start = 1
        while (start <= n && lines[start] == "") start++
        end = n
        while (end >= start && lines[end] == "") end--
        for (i = start; i <= end; i++) print lines[i]
      }
    ' "$raw_message_file" >"$message_file"

    first_line=$(IFS= read -r line <"$message_file"; printf '%s' "$line")
    if [ -z "$first_line" ]; then
      echo "opencode returned an empty commit message"
      exit 1
    fi

    echo "Commit message:"
    cat "$message_file"

    git commit -F "$message_file"
  '';
in
{
  home.packages = [ git-ai-commit ];
}
