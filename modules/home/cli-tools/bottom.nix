{ config, ... }:
let
  catppuccinMocha = {
    base00 = "1e1e2e";
    base02 = "313244";
    base03 = "45475a";
    base05 = "cdd6f4";
    base08 = "f38ba8";
    base09 = "fab387";
    base0A = "f9e2af";
    base0B = "a6e3a1";
    base0C = "94e2d5";
    base0D = "89b4fa";
    base0E = "cba6f7";
  };
  c = if (config.stylix.enable or false) then config.lib.stylix.colors else catppuccinMocha;
in
{
  xdg.configFile."bottom/bottom.toml".text = ''
    [flags]
    rate = "1s"
    retention = "10m"
    default_widget_type = "process"
    hide_table_gap = true
    show_table_scroll_position = true
    process_command = true
    tree = true
    temperature_type = "c"
    theme = "default"

    [colors]
    table_header_color = "#${c.base0E}"
    widget_title_color = "#${c.base05}"
    border_color = "#${c.base03}"
    highlighted_border_color = "#${c.base0E}"
    text_color = "#${c.base05}"
    selected_text_color = "#${c.base00}"
    selected_bg_color = "#${c.base0E}"
    graph_color = "#${c.base03}"
    high_battery_color = "#${c.base0B}"
    medium_battery_color = "#${c.base0A}"
    low_battery_color = "#${c.base08}"
    all_cpu_color = "#${c.base0E}"
    avg_cpu_color = "#${c.base0D}"
    ram_color = "#${c.base0C}"
    swap_color = "#${c.base09}"
    rx_color = "#${c.base0B}"
    tx_color = "#${c.base0D}"
  '';
}
