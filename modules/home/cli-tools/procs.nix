{ config, ... }:
let
  catppuccinMocha = {
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
  xdg.configFile."procs/config.toml".text = ''
    [[columns]]
    kind = "Pid"
    style = "#${c.base0A}|#${c.base0A}"
    numeric_search = true
    nonnumeric_search = false
    align = "Right"

    [[columns]]
    kind = "User"
    style = "#${c.base0B}|#${c.base0B}"
    numeric_search = false
    nonnumeric_search = true
    align = "Left"

    [[columns]]
    kind = "UsageCpu"
    style = "ByPercentage"
    numeric_search = false
    nonnumeric_search = false
    align = "Right"

    [[columns]]
    kind = "UsageMem"
    style = "ByPercentage"
    numeric_search = false
    nonnumeric_search = false
    align = "Right"

    [[columns]]
    kind = "CpuTime"
    style = "#${c.base0C}|#${c.base0C}"
    numeric_search = false
    nonnumeric_search = false
    align = "Right"

    [[columns]]
    kind = "MultiSlot"
    style = "ByUnit"
    numeric_search = false
    nonnumeric_search = false
    align = "Right"

    [[columns]]
    kind = "Separator"
    style = "#${c.base03}|#${c.base03}"
    numeric_search = false
    nonnumeric_search = false
    align = "Left"

    [[columns]]
    kind = "Command"
    style = "#${c.base05}|#${c.base05}"
    numeric_search = false
    nonnumeric_search = true
    align = "Left"

    [style]
    header = "#${c.base0E}|#${c.base0E}"
    unit = "#${c.base05}|#${c.base05}"
    tree = "#${c.base03}|#${c.base03}"

    [style.by_percentage]
    color_000 = "#${c.base0D}|#${c.base0D}"
    color_025 = "#${c.base0B}|#${c.base0B}"
    color_050 = "#${c.base0A}|#${c.base0A}"
    color_075 = "#${c.base09}|#${c.base09}"
    color_100 = "#${c.base08}|#${c.base08}"

    [style.by_state]
    color_d = "#${c.base08}|#${c.base08}"
    color_r = "#${c.base0B}|#${c.base0B}"
    color_s = "#${c.base0D}|#${c.base0D}"
    color_t = "#${c.base0C}|#${c.base0C}"
    color_z = "#${c.base0E}|#${c.base0E}"
    color_x = "#${c.base0E}|#${c.base0E}"
    color_k = "#${c.base0A}|#${c.base0A}"
    color_w = "#${c.base0A}|#${c.base0A}"
    color_p = "#${c.base0A}|#${c.base0A}"

    [style.by_unit]
    color_k = "#${c.base0D}|#${c.base0D}"
    color_m = "#${c.base0B}|#${c.base0B}"
    color_g = "#${c.base0A}|#${c.base0A}"
    color_t = "#${c.base09}|#${c.base09}"
    color_p = "#${c.base08}|#${c.base08}"
    color_x = "#${c.base0D}|#${c.base0D}"

    [search]
    numeric_search = "Exact"
    nonnumeric_search = "Partial"
    logic = "And"
    case = "Smart"

    [display]
    show_self = false
    show_self_parents = false
    show_thread = false
    show_thread_in_tree = true
    show_parent_in_tree = true
    show_children_in_tree = true
    show_header = true
    show_footer = false
    cut_to_terminal = true
    cut_to_pager = false
    cut_to_pipe = false
    color_mode = "Always"
    separator = "│"
    ascending = "▲"
    descending = "▼"
    tree_symbols = ["│", "─", "┬", "├", "└"]
    abbr_sid = true
    theme = "Dark"
    show_kthreads = true

    [sort]
    column = 2
    order = "Descending"

    [docker]
    path = "unix:///var/run/docker.sock"

    [pager]
    mode = "Auto"
    detect_width = false
    use_builtin = false
  '';
}
