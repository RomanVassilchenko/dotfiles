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

  # Shell completions for bw (bitwarden-cli) and rbw
  # bw completion produces Node.js deprecation noise on stderr — suppress it
  programs.zsh.initContent = ''
    if command -v bw >/dev/null 2>&1; then
      source <(bw completion --shell zsh 2>/dev/null)
    fi
    if command -v rbw >/dev/null 2>&1; then
      source <(rbw gen-completions zsh)
    fi
  '';
}
