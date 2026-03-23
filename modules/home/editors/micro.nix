{ pkgs-stable, ... }:
{
  programs.micro = {
    enable = true;
    package = pkgs-stable.micro;

    settings = {
      # UI
      ruler = true;
      scrollbar = true;
      statusformatr = "($(line),$(col)) | $(status.paste)| $(status.recording)";

      # Editing
      autoindent = true;
      tabsize = 2;
      tabstospaces = true;
      savecursor = true;
      saveundo = true;
      scrollmargin = 5;

      # Mouse (familiar from VSCode)
      mouse = true;

      # Line numbers
      relativeruler = false;

      # Soft wrap
      softwrap = true;
      wordwrap = true;

      # File handling
      autosu = true;
      mkparents = true;
      rmtrailingws = true;
      eofnewline = true;

      # Clipboard (use system clipboard)
      clipboard = "external";

      # Matching brackets
      matchbrace = true;
      matchbraceleft = true;
    };
  };

  # True color support
  home.sessionVariables.MICRO_TRUECOLOR = "1";

  # Keybindings (VSCode-like additions)
  xdg.configFile."micro/bindings.json".text = builtins.toJSON {
    # Duplicate line (Ctrl+Shift+D in VSCode, Alt+D here since terminal limitations)
    "Alt-d" = "command:duplicateline";
    # Delete line
    "Ctrl-Shift-K" = "command:deleteline";
    # Move line up/down
    "Alt-Up" = "command:movelines up";
    "Alt-Down" = "command:movelines down";
    # Toggle comment
    "Ctrl-/" = "command:comment";
    # Go to line
    "Ctrl-g" = "command:goto";
    # Command palette
    "Ctrl-Shift-P" = "command:command";
  };
}
