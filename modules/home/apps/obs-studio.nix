{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-move-transition
      obs-composite-blur
      obs-backgroundremoval
    ];
  };

  # Catppuccin Mocha theme for OBS
  # After rebuild, select theme in OBS: Settings > Appearance > Theme: Catppuccin, Style: Mocha
  xdg.configFile."obs-studio/themes/Catppuccin.obt".text = ''
    @OBSThemeMeta {
        name: 'Catppuccin';
        id: 'com.obsproject.Catppuccin';
        author: 'Xurdejl';
        dark: 'true';
    }

    @OBSThemeVars {
        --palette_window: var(--ctp_mantle);
        --palette_windowText: var(--ctp_subtext0);
        --palette_base: var(--ctp_mantle);
        --palette_alternateBase: var(--ctp_crust);
        --palette_text: var(--ctp_text);
        --palette_button: var(--ctp_surface0);
        --palette_buttonText: var(--ctp_subtext0);
        --palette_brightText: var(--ctp_subtext0);
        --palette_light: var(--ctp_surface0);
        --palette_mid: var(--ctp_base);
        --palette_dark: var(--ctp_mantle);
        --palette_shadow: var(--ctp_crust);
        --palette_primary: var(--ctp_surface1);
        --palette_primaryLight: var(--ctp_mauve);
        --palette_primaryDark: var(--ctp_crust);
        --palette_highlight: var(--ctp_mauve);
        --palette_highlightText: var(--ctp_subtext0);
        --palette_link: var(--ctp_rosewater);
        --palette_linkVisited: var(--ctp_flamingo);
        --palette_windowText_disabled: var(--ctp_overlay1);
        --palette_text_disabled: var(--ctp_overlay1);
        --palette_button_disabled: var(--ctp_base);
        --palette_buttonText_disabled: var(--ctp_mantle);
        --palette_brightText_disabled: var(--ctp_mantle);
        --palette_text_inactive: var(--ctp_subtext0);
        --palette_highlight_inactive: var(--ctp_crust);
        --palette_highlightText_inactive: var(--ctp_text);

        --font_base_value: 10;
        --spacing_base_value: 4;
        --padding_base_value: 4;
        --border_highlight: "transparent";
        --os_mac_font_base_value: 12;
        --font_base: calc(1pt * var(--font_base_value));
        --font_small: calc(0.9pt * var(--font_base_value));
        --font_large: calc(1.1pt * var(--font_base_value));
        --font_xlarge: calc(1.5pt * var(--font_base_value));
        --font_heading: calc(2.5pt * var(--font_base_value));
        --icon_base: calc(6px + var(--font_base_value));
        --spacing_base: calc(0.5px * var(--spacing_base_value));
        --spacing_large: calc(1px * var(--spacing_base_value));
        --spacing_small: calc(0.25px * var(--spacing_base_value));
        --spacing_title: 4px;
        --padding_base: calc(0.5px * var(--padding_base_value));
        --padding_large: calc(1px * var(--padding_base_value));
        --padding_xlarge: calc(1.75px * var(--padding_base_value));
        --padding_small: calc(0.25px * var(--padding_base_value));
        --padding_wide: calc(8px + calc(2 * var(--padding_base_value)));
        --padding_menu: calc(4px + calc(2 * var(--padding_base_value)));
        --padding_base_border: calc(var(--padding_base) + 1px);
        --spinbox_button_height: calc(var(--input_height_half) - 1px);
        --volume_slider: calc(calc(4px + var(--font_base_value)) / 4);
        --volume_slider_box: calc(var(--volume_slider) * 4);
        --volume_slider_label: calc(var(--volume_slider_box) * 2);
        --scrollbar_size: 12px;
        --settings_scrollbar_size: calc(var(--scrollbar_size) + 9px);
        --border_radius: 4px;
        --border_radius_small: 2px;
        --border_radius_large: 6px;
        --input_font_scale: calc(var(--font_base_value) * 2.2);
        --input_font_padding: calc(var(--padding_base_value) * 2);
        --input_height_base: calc(var(--input_font_scale) + var(--input_font_padding));
        --input_padding: var(--padding_large);
        --input_height: calc(var(--input_height_base) - calc(var(--input_padding) * 2));
        --input_height_half: calc(var(--input_height_base) / 2);
        --spacing_input: var(--spacing_base);
    }

    .bg_window { background-color: var(--ctp_base); }
    .bg-base { background-color: palette(base); }
    .text-heading { font-size: var(--font_heading); font-weight: bold; }
    .text-large { font-size: var(--font_large); }
    .text-bright { color: var(--ctp_surface0); }
    .text-muted { color: var(--ctp_overlay1); }
    .text-warning { color: var(--ctp_peach); }
    .text-danger { color: var(--ctp_maroon); }
    .text-success { color: var(--ctp_green); }

    QWidget {
        alternate-background-color: palette(base);
        color: palette(text);
        selection-background-color: var(--ctp_selection_background);
        selection-color: palette(text);
        font-size: var(--font_base);
        font-family: 'Open Sans', '.AppleSystemUIFont', Helvetica, Arial, 'MS Shell Dlg', sans-serif;
    }
    QWidget:disabled { color: var(--ctp_overlay1); }
    QDialog, QMainWindow, QStatusBar, QMenuBar, QMenu { background-color: var(--ctp_base); }

    VolumeMeter {
        qproperty-backgroundNominalColor: var(--ctp_green);
        qproperty-backgroundWarningColor: var(--ctp_peach);
        qproperty-backgroundErrorColor: var(--ctp_red);
        qproperty-foregroundNominalColor: var(--ctp_green);
        qproperty-foregroundWarningColor: var(--ctp_peach);
        qproperty-foregroundErrorColor: var(--ctp_red);
        qproperty-magnitudeColor: var(--ctp_surface0);
        qproperty-majorTickColor: var(--ctp_text);
        qproperty-minorTickColor: var(--ctp_overlay0);
    }

    OBSQTDisplay { qproperty-displayBackgroundColor: var(--ctp_crust); }
  '';

  xdg.configFile."obs-studio/themes/Catppuccin_Mocha.ovt".text = ''
    @OBSThemeMeta {
        name: 'Mocha';
        id: 'com.obsproject.Catppuccin.Mocha';
        extends: 'com.obsproject.Catppuccin';
        author: 'Xurdejl';
        dark: 'true';
    }

    @OBSThemeVars {
        --ctp_rosewater: #f5e0dc;
        --ctp_flamingo: #f2cdcd;
        --ctp_pink: #f5c2e7;
        --ctp_mauve: #cba6f7;
        --ctp_red: #f38ba8;
        --ctp_maroon: #eba0ac;
        --ctp_peach: #fab387;
        --ctp_yellow: #f9e2af;
        --ctp_green: #a6e3a1;
        --ctp_teal: #94e2d5;
        --ctp_sky: #89dceb;
        --ctp_sapphire: #74c7ec;
        --ctp_blue: #89b4fa;
        --ctp_lavender: #b4befe;
        --ctp_text: #cdd6f4;
        --ctp_subtext1: #bac2de;
        --ctp_subtext0: #a6adc8;
        --ctp_overlay2: #9399b2;
        --ctp_overlay1: #7f849c;
        --ctp_overlay0: #6c7086;
        --ctp_surface2: #585b70;
        --ctp_surface1: #45475a;
        --ctp_surface0: #313244;
        --ctp_base: #1e1e2e;
        --ctp_mantle: #181825;
        --ctp_crust: #11111b;
        --ctp_selection_background: #353649;
    }

    VolumeMeter {
        qproperty-foregroundNominalColor: #6fd266;
        qproperty-foregroundWarningColor: #f7853f;
        qproperty-foregroundErrorColor: #ec4675;
    }
  '';
}
