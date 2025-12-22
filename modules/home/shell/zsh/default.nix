{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Catppuccin Mocha colors
  mauve = "#cba6f7";
  green = "#a6e3a1";
  red = "#f38ba8";
  peach = "#fab387";
  yellow = "#f9e2af";
  blue = "#89b4fa";
  teal = "#94e2d5";
  text = "#cdd6f4";
  overlay0 = "#6c7086";
in
{
  imports = [ ];

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=${overlay0}";
    };
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
      # Catppuccin Mocha with Mauve accent
      styles = {
        # Commands and arguments
        command = "fg=${mauve},bold";
        builtin = "fg=${mauve}";
        alias = "fg=${mauve}";
        function = "fg=${blue}";
        precommand = "fg=${peach},underline";
        arg0 = "fg=${mauve}";

        # Arguments and options
        single-hyphen-option = "fg=${peach}";
        double-hyphen-option = "fg=${peach}";
        back-quoted-argument = "fg=${mauve}";

        # Paths and files
        path = "fg=${teal},underline";
        path_prefix = "fg=${teal}";
        autodirectory = "fg=${teal},underline";

        # Strings and quoting
        single-quoted-argument = "fg=${green}";
        double-quoted-argument = "fg=${green}";
        dollar-quoted-argument = "fg=${green}";
        back-double-quoted-argument = "fg=${mauve}";
        back-dollar-quoted-argument = "fg=${mauve}";

        # Variables and substitutions
        assign = "fg=${text}";
        redirection = "fg=${peach},bold";
        comment = "fg=${overlay0}";
        named-fd = "fg=${blue}";
        numeric-fd = "fg=${blue}";

        # Special
        globbing = "fg=${yellow}";
        history-expansion = "fg=${mauve}";
        commandseparator = "fg=${peach}";
        command-substitution = "fg=${text}";
        command-substitution-delimiter = "fg=${mauve}";
        process-substitution = "fg=${text}";
        process-substitution-delimiter = "fg=${mauve}";

        # Errors
        unknown-token = "fg=${red},bold";
        reserved-word = "fg=${mauve},bold";
        suffix-alias = "fg=${green},underline";
        global-alias = "fg=${yellow}";

        # Brackets (matched by brackets highlighter)
        bracket-level-1 = "fg=${mauve},bold";
        bracket-level-2 = "fg=${blue},bold";
        bracket-level-3 = "fg=${peach},bold";
        bracket-level-4 = "fg=${green},bold";
        bracket-error = "fg=${red},bold";
        cursor-matchingbracket = "fg=${text},bold,standout";
      };
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
    ];

    initContent = ''
      # XDG-compliant compinit directory
      autoload -U compinit
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

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
    };
  };
}
