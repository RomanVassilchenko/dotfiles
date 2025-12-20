{
  profile,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "root"
        "line"
      ];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
      path = "${config.xdg.stateHome}/zsh/history";
    };

    oh-my-zsh = {
      enable = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
    ];

    initContent = ''
      # XDG-compliant compinit directory
      autoload -U compinit
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

      # zsh-you-should-use: show hints after command
      export YSU_MESSAGE_POSITION="after"

      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word
      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi
    '';

    shellAliases = {
      c = "clear";
      man = "batman";

      # VPN - AQ/Dahua
      aq-vpn = "sudo systemctl start openfortivpn-dahua.service";
      aq-vpn-stop = "sudo systemctl stop openfortivpn-dahua.service";
      aq-vpn-status = "systemctl status openfortivpn-dahua.service";

      # Tailscale - Ninkear P2P (via cloudflared TCP tunnel)
      ninkear = "cloudflared access tcp --hostname headscale.romanv.dev --url 127.0.0.1:18085 & sleep 2 && sudo tailscale up --login-server=http://127.0.0.1:18085 --accept-routes";
      ninkear-stop = "sudo tailscale down; pkill -f 'cloudflared access tcp.*headscale'";
      ninkear-status = "tailscale status";
    };
  };
}
