{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      window_padding_width = 4;

      # Tab bar
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = 1;
      tab_title_template = "{index}: {title}";
    };

    keybindings = {
      # New tab / close tab
      "ctrl+t" = "new_tab_with_cwd";
      "ctrl+w" = "close_tab";

      # Navigate tabs
      "ctrl+tab" = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";

      # Jump to tab by number
      "ctrl+1" = "goto_tab 1";
      "ctrl+2" = "goto_tab 2";
      "ctrl+3" = "goto_tab 3";
      "ctrl+4" = "goto_tab 4";
      "ctrl+5" = "goto_tab 5";
      "ctrl+6" = "goto_tab 6";
      "ctrl+7" = "goto_tab 7";
      "ctrl+8" = "goto_tab 8";
      "ctrl+9" = "goto_tab 9";

      # Rename tab
      "ctrl+shift+r" = "set_tab_title";
    };
  };
}
