{
  zshPalette,
  ...
}:
{
  programs.zsh.initContent = ''
    # ===========================================
    # fast-syntax-highlighting - Catppuccin Mocha
    # ===========================================
    typeset -A FAST_HIGHLIGHT_STYLES
    FAST_HIGHLIGHT_STYLES[command]="fg=${zshPalette.mauve},bold"
    FAST_HIGHLIGHT_STYLES[builtin]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[alias]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[function]="fg=${zshPalette.blue}"
    FAST_HIGHLIGHT_STYLES[precommand]="fg=${zshPalette.peach},underline"
    FAST_HIGHLIGHT_STYLES[default]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[single-hyphen-option]="fg=${zshPalette.peach}"
    FAST_HIGHLIGHT_STYLES[double-hyphen-option]="fg=${zshPalette.peach}"
    FAST_HIGHLIGHT_STYLES[back-quoted-argument]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[path]="fg=${zshPalette.teal},underline"
    FAST_HIGHLIGHT_STYLES[path-prefix]="fg=${zshPalette.teal}"
    FAST_HIGHLIGHT_STYLES[autodirectory]="fg=${zshPalette.teal},underline"
    FAST_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${zshPalette.green}"
    FAST_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${zshPalette.green}"
    FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${zshPalette.green}"
    FAST_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[assign]="fg=${zshPalette.text}"
    FAST_HIGHLIGHT_STYLES[redirection]="fg=${zshPalette.peach},bold"
    FAST_HIGHLIGHT_STYLES[comment]="fg=${zshPalette.overlay0}"
    FAST_HIGHLIGHT_STYLES[named-fd]="fg=${zshPalette.blue}"
    FAST_HIGHLIGHT_STYLES[numeric-fd]="fg=${zshPalette.blue}"
    FAST_HIGHLIGHT_STYLES[globbing]="fg=${zshPalette.yellow}"
    FAST_HIGHLIGHT_STYLES[history-expansion]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[commandseparator]="fg=${zshPalette.peach}"
    FAST_HIGHLIGHT_STYLES[command-substitution]="fg=${zshPalette.text}"
    FAST_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[process-substitution]="fg=${zshPalette.text}"
    FAST_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=${zshPalette.mauve}"
    FAST_HIGHLIGHT_STYLES[unknown-token]="fg=${zshPalette.red},bold"
    FAST_HIGHLIGHT_STYLES[reserved-word]="fg=${zshPalette.mauve},bold"
    FAST_HIGHLIGHT_STYLES[suffix-alias]="fg=${zshPalette.green},underline"
    FAST_HIGHLIGHT_STYLES[global-alias]="fg=${zshPalette.yellow}"
    FAST_HIGHLIGHT_STYLES[bracket-level-1]="fg=${zshPalette.mauve},bold"
    FAST_HIGHLIGHT_STYLES[bracket-level-2]="fg=${zshPalette.blue},bold"
    FAST_HIGHLIGHT_STYLES[bracket-level-3]="fg=${zshPalette.peach},bold"
    FAST_HIGHLIGHT_STYLES[bracket-level-4]="fg=${zshPalette.green},bold"
    FAST_HIGHLIGHT_STYLES[bracket-error]="fg=${zshPalette.red},bold"
    FAST_HIGHLIGHT_STYLES[cursor-matchingbracket]="fg=${zshPalette.text},bold,standout"
  '';
}
