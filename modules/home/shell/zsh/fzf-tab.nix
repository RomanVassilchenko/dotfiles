{
  lib,
  zshPalette,
  ...
}:
{
  programs.zsh.initContent = lib.mkAfter ''
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
    zstyle ':fzf-tab:*' fzf-flags --color=bg+:${zshPalette.overlay0},spinner:${zshPalette.mauve},hl:${zshPalette.mauve} \
      --color=fg:${zshPalette.text},header:${zshPalette.mauve},info:${zshPalette.peach},pointer:${zshPalette.mauve} \
      --color=marker:${zshPalette.green},fg+:${zshPalette.text},prompt:${zshPalette.mauve},hl+:${zshPalette.mauve}

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
  '';
}
