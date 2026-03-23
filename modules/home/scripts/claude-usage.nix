{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "claude-usage" ''
      # Claude API usage via unified rate limit headers
      # Usage: claude-usage [all] [--short] [--plain]

      SHORT=0
      PLAIN=0

      for arg in "$@"; do
        case "$arg" in
          --short) SHORT=1 ;;
          --plain) PLAIN=1 ;;
          all) ;;
        esac
      done

      CREDS="$HOME/.claude/.credentials.json"
      if [ ! -f "$CREDS" ]; then exit 1; fi

      TOKEN=$(${pkgs.jq}/bin/jq -r '.claudeAiOauth.accessToken // empty' "$CREDS" 2>/dev/null)
      if [ -z "$TOKEN" ]; then exit 1; fi

      # Use a cache to avoid making API calls too frequently (60s TTL)
      CACHE_FILE="$HOME/.claude/cache/claude-usage-headers.cache"
      CACHE_TTL=60
      NOW=$(${pkgs.coreutils}/bin/date +%s)

      if [ -f "$CACHE_FILE" ]; then
        CACHE_AGE=$((NOW - $(${pkgs.coreutils}/bin/stat -c '%Y' "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [ "$CACHE_AGE" -lt "$CACHE_TTL" ]; then
          HEADERS=$(cat "$CACHE_FILE")
        fi
      fi

      if [ -z "$HEADERS" ]; then
        HEADERS=$(${pkgs.curl}/bin/curl -s -D - -o /dev/null \
          -H "Authorization: Bearer $TOKEN" \
          -H "anthropic-version: 2023-06-01" \
          -H "anthropic-beta: oauth-2025-04-20" \
          -H "content-type: application/json" \
          --max-time 5 \
          "https://api.anthropic.com/v1/messages" \
          -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
          2>/dev/null)
        if [ -n "$HEADERS" ]; then
          mkdir -p "$(dirname "$CACHE_FILE")"
          echo "$HEADERS" > "$CACHE_FILE"
        else
          exit 1
        fi
      fi

      get_header() {
        echo "$HEADERS" | grep -i "^$1:" | head -1 | sed 's/^[^:]*: *//' | tr -d '\r'
      }

      fmt_duration() {
        local secs=$1
        [ "$secs" -le 0 ] && echo "0m" && return
        local d=$((secs / 86400))
        local h=$(( (secs % 86400) / 3600 ))
        local m=$(( (secs % 3600) / 60 ))
        if [ "$d" -gt 0 ]; then
          echo "''${d}d''${h}h"
        elif [ "$h" -gt 0 ]; then
          echo "''${h}h''${m}m"
        else
          echo "''${m}m"
        fi
      }

      H5_RESET=$(get_header "anthropic-ratelimit-unified-5h-reset")
      H5_UTIL=$(get_header "anthropic-ratelimit-unified-5h-utilization")
      H7_RESET=$(get_header "anthropic-ratelimit-unified-7d-reset")
      H7_UTIL=$(get_header "anthropic-ratelimit-unified-7d-utilization")

      if [ -z "$H5_RESET" ] || [ -z "$H7_RESET" ]; then exit 1; fi

      H5_LEFT=$((H5_RESET - NOW))
      H7_LEFT=$((H7_RESET - NOW))

      H5_PCT=$(echo "$H5_UTIL" | awk '{printf "%d", $1 * 100}')
      H7_PCT=$(echo "$H7_UTIL" | awk '{printf "%d", $1 * 100}')

      H5_TIME=$(fmt_duration "$H5_LEFT")
      H7_TIME=$(fmt_duration "$H7_LEFT")

      if [ "$PLAIN" -eq 1 ]; then
        SEP="|"
      else
        SEP="│"
      fi

      if [ "$SHORT" -eq 1 ]; then
        echo "''${H5_TIME} ''${H5_PCT}% ''${SEP} ''${H7_TIME} ''${H7_PCT}%"
      else
        echo "5h: ''${H5_TIME} left, ''${H5_PCT}% used ''${SEP} 7d: ''${H7_TIME} left, ''${H7_PCT}% used"
      fi
    '')
  ];
}
