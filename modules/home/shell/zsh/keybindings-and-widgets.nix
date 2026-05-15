{
  lib,
  ...
}:
{
  programs.zsh.initContent = lib.mkAfter ''
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
  '';
}
