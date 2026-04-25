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
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion = {
      enable = true;
      highlight = "fg=${overlay0}";
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

    initContent = ''
      # XDG-compliant compinit with 24h cache
      autoload -U compinit
      if [[ -n "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"(#qN.mh+24) ]]; then
        compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
      else
        compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
      fi

      # ===========================================
      # fast-syntax-highlighting — Catppuccin Mocha
      # ===========================================
      typeset -A FAST_HIGHLIGHT_STYLES
      FAST_HIGHLIGHT_STYLES[command]="fg=${mauve},bold"
      FAST_HIGHLIGHT_STYLES[builtin]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[alias]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[function]="fg=${blue}"
      FAST_HIGHLIGHT_STYLES[precommand]="fg=${peach},underline"
      FAST_HIGHLIGHT_STYLES[default]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[single-hyphen-option]="fg=${peach}"
      FAST_HIGHLIGHT_STYLES[double-hyphen-option]="fg=${peach}"
      FAST_HIGHLIGHT_STYLES[back-quoted-argument]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[path]="fg=${teal},underline"
      FAST_HIGHLIGHT_STYLES[path-prefix]="fg=${teal}"
      FAST_HIGHLIGHT_STYLES[autodirectory]="fg=${teal},underline"
      FAST_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${green}"
      FAST_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${green}"
      FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${green}"
      FAST_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[assign]="fg=${text}"
      FAST_HIGHLIGHT_STYLES[redirection]="fg=${peach},bold"
      FAST_HIGHLIGHT_STYLES[comment]="fg=${overlay0}"
      FAST_HIGHLIGHT_STYLES[named-fd]="fg=${blue}"
      FAST_HIGHLIGHT_STYLES[numeric-fd]="fg=${blue}"
      FAST_HIGHLIGHT_STYLES[globbing]="fg=${yellow}"
      FAST_HIGHLIGHT_STYLES[history-expansion]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[commandseparator]="fg=${peach}"
      FAST_HIGHLIGHT_STYLES[command-substitution]="fg=${text}"
      FAST_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[process-substitution]="fg=${text}"
      FAST_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=${mauve}"
      FAST_HIGHLIGHT_STYLES[unknown-token]="fg=${red},bold"
      FAST_HIGHLIGHT_STYLES[reserved-word]="fg=${mauve},bold"
      FAST_HIGHLIGHT_STYLES[suffix-alias]="fg=${green},underline"
      FAST_HIGHLIGHT_STYLES[global-alias]="fg=${yellow}"
      FAST_HIGHLIGHT_STYLES[bracket-level-1]="fg=${mauve},bold"
      FAST_HIGHLIGHT_STYLES[bracket-level-2]="fg=${blue},bold"
      FAST_HIGHLIGHT_STYLES[bracket-level-3]="fg=${peach},bold"
      FAST_HIGHLIGHT_STYLES[bracket-level-4]="fg=${green},bold"
      FAST_HIGHLIGHT_STYLES[bracket-error]="fg=${red},bold"
      FAST_HIGHLIGHT_STYLES[cursor-matchingbracket]="fg=${text},bold,standout"

      # ===========================================
      # fzf-tab Configuration
      # ===========================================
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu no
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*' squeeze-slashes true

      # Catppuccin Mocha colors for fzf-tab
      zstyle ':fzf-tab:*' fzf-flags --color=bg+:${overlay0},spinner:${mauve},hl:${mauve} \
        --color=fg:${text},header:${mauve},info:${peach},pointer:${mauve} \
        --color=marker:${green},fg+:${text},prompt:${mauve},hl+:${mauve}

      # Show group descriptions
      zstyle ':fzf-tab:*' show-group full

      # Switch groups with < and >
      zstyle ':fzf-tab:*' switch-group '<' '>'

      # Preview directory contents
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --color=always --icons=always $realpath'
      zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --tree --level=2 --color=always --icons=always $realpath'
      zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza --tree --level=2 --color=always --icons=always $realpath'

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
      # Edit current command in $EDITOR (Ctrl+X, Ctrl+E)
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # Quick sudo prefix (Esc, Esc)
      bindkey -s '\e\e' '^Asudo ^E'

      # Accept autosuggestion with Ctrl+Space
      bindkey '^ ' autosuggest-accept
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

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
        printf '%s' "$BUFFER" | wl-copy &!
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

      # Open the current buffer in the default terminal editor fast
      function edit-in-micro() {
        BUFFER="micro"
        zle accept-line
      }
      zle -N edit-in-micro
      bindkey '^X^M' edit-in-micro

      # Open the current directory in a GUI editor.
      function open-in-vscode() {
        BUFFER="code ."
        zle accept-line
      }
      zle -N open-in-vscode
      bindkey '^X^V' open-in-vscode

      function open-in-zed() {
        BUFFER="zeditor ."
        zle accept-line
      }
      zle -N open-in-zed
      bindkey '^X^Z' open-in-zed

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
      alias -g G='| rg'

      # ===========================================
      # Search & Navigation Helpers
      # ===========================================
      fcd() {
        local query
        local dir
        query="''${1:-.}"
        dir=$(fd --type d --hidden --follow --exclude .git "$query" . | fzf \
          --prompt='󰉋 ' \
          --preview 'eza --tree --level=2 --color=always --icons=always {} 2>/dev/null') || return
        cd "$dir"
      }

      fe() {
        local query
        local file
        query="''${1:-.}"
        file=$(fd --type f --hidden --follow --exclude .git "$query" . | fzf \
          --prompt='󰈔 ' \
          --preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null') || return
        micro "$file"
      }

      frg() {
        local match file line
        match=$(rg --line-number --no-heading --color=always --smart-case "$@" | fzf \
          --ansi \
          --delimiter ':' \
          --prompt='󰱼 ' \
          --preview 'bat --color=always --style=numbers --highlight-line {2} --line-range {2}:$(({2}+80)) {1} 2>/dev/null') || return
        file=$(printf '%s' "$match" | cut -d: -f1)
        line=$(printf '%s' "$match" | cut -d: -f2)
        [ -n "$file" ] && micro +"$line" "$file"
      }

      ai-session() {
        local tool="''${1:-claude}"
        case "$tool" in
          claude|opencode|codex|gemini)
            "$tool" "''${@:2}"
            ;;
          *)
            printf 'Unknown AI tool: %s\n' "$tool"
            return 1
            ;;
        esac
      }

      hs() {
        atuin stats "$@"
      }

      cu() {
        claude-usage "$@"
      }

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
          'cleanup:Trash backup files, GC old generations'
          'backup:Backup dotfiles to ninkear'
          'cache:Cache management (build, start, status)'
          'server:Server management (rebuild, update)'
          'doctor:Run system health checks'
          'trim:Run fstrim for SSD'
          'help:Show help'
        )

        local -a rebuild_opts
        rebuild_opts=(
          '--dry:Show build/download plan without sudo'
          '--dry-activate:Build and preview activation changes'
          '--build:Build only, do not activate'
          '--test:Activate until next boot only'
          '--plain:Disable nix-output-monitor'
          '--cores:Limit CPU cores'
          '--jobs:Limit parallel jobs'
        )

        local -a cache_subcmds
        cache_subcmds=('build:Build all configs locally' 'start:Start remote build on ninkear' 'status:Check remote build progress')

        local -a server_subcmds
        server_subcmds=('rebuild:Pull and rebuild on ninkear' 'update:Sync, update flake, rebuild ninkear')

        case "$words[2]" in
          rebuild|rebuild-boot|update)
            _describe -t rebuild_opts 'options' rebuild_opts
            ;;
          cache)
            _describe -t cache_subcmds 'subcommands' cache_subcmds
            ;;
          server)
            _describe -t server_subcmds 'subcommands' server_subcmds
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
      cat = "bat";
      v = "code --wait";
      vz = "zed .";
      lg = "lazygit";
      ld = "lazydocker";
      dux = "dust";
      dui = "ncdu";
      cc = "claude";
      oc = "opencode";
      cx = "codex";
      gem = "gemini";
    };
  };
}
