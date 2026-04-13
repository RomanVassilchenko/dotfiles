{ pkgs-stable, lib, ... }:
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

  # bw (bitwarden-cli) - configure server URL on activation
  home.activation.configureBwServer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs-stable.bitwarden-cli}/bin/bw config server https://bitwarden.romanv.dev
  '';

  # Shell completions for bw (bitwarden-cli) and rbw
  programs.zsh.initContent = ''
    if command -v bw >/dev/null 2>&1; then
      source <(bw completion --shell zsh)
    fi
    if command -v rbw >/dev/null 2>&1; then
      source <(rbw gen-completions zsh)
    fi
  '';
}
