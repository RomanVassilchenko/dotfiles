#!/usr/bin/env bash

# Catppuccin Mocha palette
C_RED="\033[38;2;243;139;168m"
C_YELLOW="\033[38;2;249;226;175m"
C_GREEN="\033[38;2;166;227;161m"
C_CYAN="\033[38;2;137;220;235m"
C_BLUE="\033[38;2;137;180;250m"
C_MAUVE="\033[38;2;203;166;247m"
C_GRAY="\033[38;2;108;112;134m"
C_RESET="\033[0m"

# Read JSON input from stdin
input=$(cat)

# Extract current directory
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)
[ -z "$current_dir" ] && current_dir="$PWD"

# Git branch
git_branch=""
git_dirty=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$git_branch" ]; then
    git -C "$current_dir" --no-optional-locks diff-index --quiet HEAD 2>/dev/null || git_dirty="*"
  fi
fi

# Shorten directory path
short_dir=$(echo "$current_dir" | sed "s|^$HOME|~|" | awk -F'/' '{
  n = NF
  if (n <= 3) print $0
  else printf "%s/…/%s/%s", $1, $(n-1), $n
}')

# Context window
usage=$(echo "$input" | jq '.context_window.current_usage' 2>/dev/null)
size=$(echo "$input" | jq '.context_window.context_window_size // 200000' 2>/dev/null)

if [ "$usage" != "null" ] && [ -n "$usage" ]; then
  current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
else
  current=0
fi

autocompact=$((size * 775 / 1000))
pct=$((current * 100 / autocompact))
remaining=$((autocompact - current))
[ $remaining -lt 0 ] && {
  remaining=0
  pct=100
}

[ $remaining -ge 1000 ] && remaining_fmt="$((remaining / 1000))k" || remaining_fmt="$remaining"

# Color by usage
[ $pct -gt 80 ] && pct_color="$C_RED" || { [ $pct -gt 60 ] && pct_color="$C_YELLOW" || pct_color="$C_GREEN"; }

# Progress bar
bar_width=10
filled=$((pct * bar_width / 100))
[ $filled -gt $bar_width ] && filled=$bar_width
[ $filled -lt 0 ] && filled=0

bar=""
for ((i = 0; i < bar_width; i++)); do
  [ $i -lt $filled ] && bar+="▓" || bar+="░"
done

# Claude API usage
claude_info=$(claude-usage all --short --plain 2>/dev/null)

# Build status line
printf "${C_MAUVE}%s${C_RESET}" "$short_dir"

[ -n "$git_branch" ] && printf " ${C_GRAY}│${C_RESET} ${C_CYAN} %s${C_RED}%s${C_RESET}" "$git_branch" "$git_dirty"

printf " ${C_GRAY}│${C_RESET} ${pct_color}%s${C_GRAY}[${pct_color}%s${C_GRAY}]${C_RESET}%s" "$pct%" "$bar" "$remaining_fmt"

[ -n "$claude_info" ] && printf " ${C_GRAY}│${C_MAUVE} 󰚩  ${C_RESET}%s" "$claude_info"

exit 0
