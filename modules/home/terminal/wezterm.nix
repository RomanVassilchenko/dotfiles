{ pkgs, ... }:
{
  home.packages = [ pkgs.wezterm ];

  xdg.configFile."wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm'
    local act = wezterm.action

    wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
      local title = tab.active_pane.title

      if title == nil or title == "" then
        title = "terminal"
      end

      title = wezterm.truncate_right(title, max_width - 6)

      local bg = "#181825"
      local fg = "#7F849C"

      if tab.is_active then
        bg = "#313244"
        fg = "#CDD6F4"
      elseif hover then
        bg = "#24273A"
        fg = "#BAC2DE"
      end

      return {
        { Background = { Color = "#11111B" } },
        { Foreground = { Color = "#11111B" } },
        { Text = "  " },
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = "  " .. title .. "  " },
        { Background = { Color = "#11111B" } },
        { Foreground = { Color = "#11111B" } },
        { Text = "  " },
      }
    end)

    local config = wezterm.config_builder()

    config.enable_wayland = true
    config.enable_kitty_keyboard = false
    config.adjust_window_size_when_changing_font_size = false

    config.font = wezterm.font_with_fallback {
      'JetBrainsMono Nerd Font Mono',
      'Noto Color Emoji',
    }
    config.font_size = 12.0
    config.line_height = 1.08
    config.cell_width = 1.0
    config.harfbuzz_features = {
      'calt=1',
      'clig=1',
      'liga=1',
    }

    config.window_padding = {
      left = 12,
      right = 12,
      top = 12,
      bottom = 8,
    }
    config.window_decorations = 'NONE'
    config.window_background_opacity = 1.0
    config.text_background_opacity = 1.0
    config.inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.75,
    }

    config.default_cursor_style = 'BlinkingBlock'
    config.cursor_blink_rate = 500
    config.cursor_blink_ease_in = 'Linear'
    config.cursor_blink_ease_out = 'Linear'
    config.animation_fps = 120
    config.max_fps = 120
    config.window_close_confirmation = 'NeverPrompt'
    config.scrollback_lines = 10000

    config.use_fancy_tab_bar = false
    config.hide_tab_bar_if_only_one_tab = false
    config.show_new_tab_button_in_tab_bar = false
    config.show_tab_index_in_tab_bar = false
    config.tab_bar_at_bottom = false
    config.tab_max_width = 28

    config.mouse_bindings = {
      {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = 'NONE',
        action = act.ScrollByLine(-3),
      },
      {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = 'NONE',
        action = act.ScrollByLine(3),
      },
    }

    config.keys = {
      {
        key = 'Enter',
        mods = 'SHIFT',
        action = act.SendString '\x1b\r',
      },
      {
        key = 't',
        mods = 'CTRL|SHIFT',
        action = act.SpawnTab 'CurrentPaneDomain',
      },
      {
        key = 'w',
        mods = 'CTRL|SHIFT',
        action = act.CloseCurrentTab { confirm = false },
      },
      {
        key = 'n',
        mods = 'CTRL|SHIFT',
        action = act.SpawnWindow,
      },
      {
        key = 'q',
        mods = 'CTRL|SHIFT',
        action = act.QuitApplication,
      },
      {
        key = 'Tab',
        mods = 'CTRL',
        action = act.ActivateTabRelative(1),
      },
      {
        key = 'Tab',
        mods = 'CTRL|SHIFT',
        action = act.ActivateTabRelative(-1),
      },
      {
        key = 'PageUp',
        mods = 'CTRL',
        action = act.ActivateTabRelative(-1),
      },
      {
        key = 'PageDown',
        mods = 'CTRL',
        action = act.ActivateTabRelative(1),
      },
      {
        key = 'PageUp',
        mods = 'SHIFT',
        action = act.ScrollByPage(-1),
      },
      {
        key = 'PageDown',
        mods = 'SHIFT',
        action = act.ScrollByPage(1),
      },
      {
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
        action = act.ActivateTabRelative(-1),
      },
      {
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
        action = act.ActivateTabRelative(1),
      },
      {
        key = 'LeftArrow',
        mods = 'ALT|SHIFT',
        action = act.MoveTabRelative(-1),
      },
      {
        key = 'RightArrow',
        mods = 'ALT|SHIFT',
        action = act.MoveTabRelative(1),
      },
      {
        key = '1',
        mods = 'ALT',
        action = act.ActivateTab(0),
      },
      {
        key = '2',
        mods = 'ALT',
        action = act.ActivateTab(1),
      },
      {
        key = '3',
        mods = 'ALT',
        action = act.ActivateTab(2),
      },
      {
        key = '4',
        mods = 'ALT',
        action = act.ActivateTab(3),
      },
      {
        key = '5',
        mods = 'ALT',
        action = act.ActivateTab(4),
      },
      {
        key = '6',
        mods = 'ALT',
        action = act.ActivateTab(5),
      },
      {
        key = '7',
        mods = 'ALT',
        action = act.ActivateTab(6),
      },
      {
        key = '8',
        mods = 'ALT',
        action = act.ActivateTab(7),
      },
      {
        key = '9',
        mods = 'ALT',
        action = act.ActivateLastTab,
      },
    }

    config.colors = {
      foreground = '#CDD6F4',
      background = '#1E1E2E',
      cursor_bg = '#F5E0DC',
      cursor_border = '#F5E0DC',
      cursor_fg = '#1E1E2E',
      selection_bg = '#585B70',
      selection_fg = '#CDD6F4',
      split = '#6C7086',
      scrollbar_thumb = '#585B70',
      ansi = {
        '#45475A',
        '#F38BA8',
        '#A6E3A1',
        '#F9E2AF',
        '#89B4FA',
        '#F5C2E7',
        '#94E2D5',
        '#BAC2DE',
      },
      brights = {
        '#585B70',
        '#F38BA8',
        '#A6E3A1',
        '#F9E2AF',
        '#89B4FA',
        '#F5C2E7',
        '#94E2D5',
        '#A6ADC8',
      },
      tab_bar = {
        background = '#11111B',
        active_tab = {
          bg_color = '#313244',
          fg_color = '#CDD6F4',
          intensity = 'Bold',
        },
        inactive_tab = {
          bg_color = '#181825',
          fg_color = '#7F849C',
        },
        inactive_tab_hover = {
          bg_color = '#24273A',
          fg_color = '#CDD6F4',
        },
        new_tab = {
          bg_color = '#11111B',
          fg_color = '#7F849C',
        },
        new_tab_hover = {
          bg_color = '#313244',
          fg_color = '#CDD6F4',
        },
      },
    }

    return config
  '';
}
