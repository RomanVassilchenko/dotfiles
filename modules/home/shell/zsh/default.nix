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

      # zsh-you-should-use: just show hints after command, don't block
      export YSU_MESSAGE_POSITION="after"
      export YSU_HARDCORE=0

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

      # VPN
      aq-vpn = "sudo systemctl start openfortivpn-dahua.service";
      aq-vpn-stop = "sudo systemctl stop openfortivpn-dahua.service";
      aq-vpn-status = "systemctl status openfortivpn-dahua.service";

      # Git shortcuts (no 'git' prefix needed)
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gb = "git branch --sort=-committerdate";
      gc = "git commit";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gco = "git checkout";
      gd = "git diff";
      gds = "git diff --staged";
      gf = "git fetch --all --prune";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      glo = "git log --oneline --decorate --all --graph";
      gp = "git pull";
      gpu = "git push";
      gpuf = "git push --force-with-lease";
      gr = "git restore";
      grs = "git restore --staged";
      gs = "git status";
      gst = "git stash";
      gstp = "git stash pop";
      gw = "git switch";
      gwc = "git switch -c";
    };
  };
}
