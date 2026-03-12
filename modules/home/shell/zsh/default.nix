{
  pkgs,
  lib,
  config,
  ...
}:
let
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
    dotDir = "${config.xdg.configHome}/zsh";
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
      styles = {
        command = "fg=${mauve},bold";
        builtin = "fg=${mauve}";
        alias = "fg=${mauve}";
        function = "fg=${blue}";
        precommand = "fg=${peach},underline";
        arg0 = "fg=${mauve}";

        single-hyphen-option = "fg=${peach}";
        double-hyphen-option = "fg=${peach}";
        back-quoted-argument = "fg=${mauve}";

        path = "fg=${teal},underline";
        path_prefix = "fg=${teal}";
        autodirectory = "fg=${teal},underline";

        single-quoted-argument = "fg=${green}";
        double-quoted-argument = "fg=${green}";
        dollar-quoted-argument = "fg=${green}";
        back-double-quoted-argument = "fg=${mauve}";
        back-dollar-quoted-argument = "fg=${mauve}";

        assign = "fg=${text}";
        redirection = "fg=${peach},bold";
        comment = "fg=${overlay0}";
        named-fd = "fg=${blue}";
        numeric-fd = "fg=${blue}";

        globbing = "fg=${yellow}";
        history-expansion = "fg=${mauve}";
        commandseparator = "fg=${peach}";
        command-substitution = "fg=${text}";
        command-substitution-delimiter = "fg=${mauve}";
        process-substitution = "fg=${text}";
        process-substitution-delimiter = "fg=${mauve}";

        unknown-token = "fg=${red},bold";
        reserved-word = "fg=${mauve},bold";
        suffix-alias = "fg=${green},underline";
        global-alias = "fg=${yellow}";

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
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = ''
      # XDG-compliant compinit directory
      autoload -U compinit
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

      # ===========================================
      # fzf-tab Configuration
      # ===========================================
      # Catppuccin Mocha colors for fzf-tab
      zstyle ':fzf-tab:*' fzf-flags --color=bg+:${overlay0},spinner:${mauve},hl:${mauve} \
        --color=fg:${text},header:${mauve},info:${peach},pointer:${mauve} \
        --color=marker:${green},fg+:${text},prompt:${mauve},hl+:${mauve}

      # Show group descriptions
      zstyle ':fzf-tab:*' show-group full

      # Switch groups with < and >
      zstyle ':fzf-tab:*' switch-group '<' '>'

      # Preview directory contents
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --color=always $realpath'

      # Preview file contents
      zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath'
      zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath'

      # Preview for kill/ps commands
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps -p $word -o pid,user,%cpu,%mem,command'
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

      # Git completions
      zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | head -100'
      zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
      zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always -10 $word'

      # Systemctl preview
      zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

      # ===========================================
      # Keybindings
      # ===========================================
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word

      # Edit current command in $EDITOR (Ctrl+X, Ctrl+E)
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # Quick sudo prefix (Esc, Esc)
      bindkey -s '\e\e' '^Asudo ^E'

      # Accept autosuggestion with Ctrl+Space
      bindkey '^ ' autosuggest-accept

      # ===========================================
      # Custom Widgets
      # ===========================================
      # Clear screen and scrollback (Ctrl+X, Ctrl+L)
      function clear-screen-and-scrollback() {
        echoti civis >"$TTY"
        printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
        echoti cnorm >"$TTY"
        zle redisplay
      }
      zle -N clear-screen-and-scrollback
      bindkey '^X^L' clear-screen-and-scrollback

      # Copy current command to clipboard (Ctrl+X, Ctrl+C)
      function copy-buffer-to-clipboard() {
        echo -n "$BUFFER" | wl-copy
        zle -M "Copied to clipboard"
      }
      zle -N copy-buffer-to-clipboard
      bindkey '^X^C' copy-buffer-to-clipboard

      # Toggle fg/bg with Ctrl+Z
      function toggle-fg-bg() {
        if [[ -n $(jobs) ]]; then
          fg
        fi
      }
      zle -N toggle-fg-bg
      bindkey '^Z' toggle-fg-bg

      # ===========================================
      # zmv - Advanced Batch Rename/Move
      # ===========================================
      autoload -Uz zmv

      # ===========================================
      # Global Aliases (usable anywhere in command)
      # ===========================================
      alias -g NE='2>/dev/null'
      alias -g NO='>/dev/null'
      alias -g NUL='>/dev/null 2>&1'
      alias -g J='| jq'
      alias -g C='| wl-copy'

      # ===========================================
      # Suffix Aliases (type filename to open it)
      # ===========================================
      alias -s {png,jpg,jpeg,gif,webp,svg,bmp}=xdg-open
      alias -s {mp4,mkv,avi,mov,webm}=xdg-open
      alias -s {mp3,flac,wav,ogg}=xdg-open
      alias -s {pdf,epub}=xdg-open
      alias -s {html,htm}=xdg-open
      alias -s {doc,docx,odt,xls,xlsx,ppt,pptx}=xdg-open
      alias -s json=jless
      alias -s {txt,md,log}=bat
      alias -s {go,rs,py,js,ts,nix,sh,lua}=$EDITOR

      # ===========================================
      # dot CLI Completions
      # ===========================================
      _dot() {
        local -a commands
        commands=(
          'rebuild:Rebuild NixOS system'
          'rebuild-boot:Rebuild for next boot'
          'update:Update flake inputs and rebuild'
          'format:Format files (nix, md, sh, all)'
          'cache:Cache management (build, start, status, upgrade)'
          'cleanup:Clean old generations'
          'backup:Backup dotfiles to ninkear'
          'doctor:Run system health checks'
          'trim:Run fstrim for SSD'
          'help:Show help'
        )

        local -a format_types
        format_types=('nix:Format Nix files' 'md:Format Markdown files' 'sh:Format shell scripts' 'all:Format all files')

        local -a rebuild_opts
        rebuild_opts=('--dry:Show what would be done' '--ask:Ask for confirmation' '--cores:Limit CPU cores' '--verbose:Verbose output' '--no-nom:Disable nix-output-monitor')

        local -a cache_subcmds
        cache_subcmds=('build:Build all configs locally' 'start:Start remote build on ninkear' 'status:Check remote build progress' 'upgrade:Run auto-upgrade (server)')

        local -a cleanup_opts
        cleanup_opts=('--gc:Run garbage collection')

        case "$words[2]" in
          format)
            _describe -t format_types 'format types' format_types
            ;;
          rebuild|rebuild-boot|update)
            _describe -t rebuild_opts 'options' rebuild_opts
            ;;
          cache)
            _describe -t cache_subcmds 'subcommands' cache_subcmds
            ;;
          cleanup)
            _describe -t cleanup_opts 'options' cleanup_opts
            ;;
          *)
            _describe -t commands 'dot commands' commands
            ;;
        esac
      }
      compdef _dot dot

      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi
    '';

    shellAliases = {
      c = "clear";
      man = "batman";
      rm = "trash-put";
    };
  };
}
