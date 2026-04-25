{ pkgs-stable, ... }:
{
  # rbw - Caching Bitwarden CLI with home-manager integration
  # Handles config file generation and shell completions automatically
  programs.rbw = {
    enable = true;
    settings = {
      email = "roman.vassilchenko.work@gmail.com";
      base_url = "https://bitwarden.romanv.dev";
      pinentry = pkgs-stable.pinentry-qt;
    };
  };

  # Shell completions for bw (bitwarden-cli) and rbw.
  # Generating bw completions is slow, so cache generated output between shells.
  programs.zsh.initContent = ''
    _zsh_source_cached_completion() {
      local name cache_dir cache_file tmp_file
      name="$1"
      shift
      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
      cache_file="$cache_dir/$name.zsh"
      tmp_file="$cache_file.$$"

      [[ -d "$cache_dir" ]] || command mkdir -p "$cache_dir"
      if [[ ! -s "$cache_file" || "$commands[$1]" -nt "$cache_file" ]]; then
        if "$@" >| "$tmp_file" 2>/dev/null; then
          command mv -f "$tmp_file" "$cache_file"
        else
          command rm -f "$tmp_file"
        fi
      fi

      [[ -s "$cache_file" ]] && source "$cache_file"
    }

    if command -v bw >/dev/null 2>&1; then
      _zsh_source_cached_completion bw bw completion --shell zsh
    fi
    if command -v rbw >/dev/null 2>&1; then
      _zsh_source_cached_completion rbw rbw gen-completions zsh
    fi

    unfunction _zsh_source_cached_completion
  '';
}
