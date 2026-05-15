{
  config,
  pkgs,
  zshPalette,
  ...
}:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    completionInit = ''
      autoload -Uz compinit
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

      zcompdump="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
      zcompdump_refresh=("$zcompdump"(N.mh+24))
      mkdir -p "''${zcompdump:h}"
      if [[ ! -e "$zcompdump" || ''${#zcompdump_refresh[@]} -gt 0 ]]; then
        compinit -d "$zcompdump"
      else
        compinit -C -d "$zcompdump"
      fi
      unset zcompdump zcompdump_refresh
    '';
    autosuggestion = {
      enable = true;
      highlight = "fg=${zshPalette.overlay0}";
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      save = 50000;
      size = 50000;
      path = "${config.xdg.stateHome}/zsh/history";
    };

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };
}
