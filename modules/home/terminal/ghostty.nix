{ pkgs, config, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;

    settings = {
      # Theme - Catppuccin Mocha
      theme = "Catppuccin Mocha";

      # Font
      font-size = 12;

      # Window
      window-padding-x = 4;
      window-padding-y = 4;
      window-decoration = true;

      # Transparency (for blur effect)
      background-opacity = 0.92;

      # Scrollback
      scrollback-limit = 10000;

      # Mouse
      mouse-hide-while-typing = true;

      # Cursor
      cursor-style = "block";
      cursor-style-blink = true;

      # Shell integration
      shell-integration = "detect";
      shell-integration-features = "cursor,sudo,title";

      # Clipboard
      clipboard-read = "allow";
      clipboard-write = "allow";
      clipboard-paste-protection = false;

      # Tabs
      window-theme = "auto";

      # Keybindings
      # Claude Code specific - Shift+Enter sends ESC + Enter
      keybind = "shift+enter=text:\\x1b\\r";
    };
  };
}
