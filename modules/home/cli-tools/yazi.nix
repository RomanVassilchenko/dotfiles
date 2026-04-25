{ config, ... }:
let
  catppuccinMocha = {
    base00 = "1e1e2e";
    base01 = "181825";
    base02 = "313244";
    base03 = "45475a";
    base04 = "585b70";
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
  xdg.configFile."yazi/yazi.toml".text = ''
    [manager]
    ratio = [1, 3, 4]
    sort_by = "natural"
    sort_sensitive = false
    sort_reverse = false
    sort_dir_first = true
    linemode = "size"
    show_hidden = false
    show_symlink = true
    scrolloff = 8

    [preview]
    tab_size = 2
    max_width = 1200
    max_height = 1800
    cache_dir = ""
    ueberzug_scale = 1
    ueberzug_offset = [0, 0, 0, 0]

    [opener]
    edit = [
      { run = 'micro "$@"', block = true, for = "unix" },
    ]
    open = [
      { run = 'xdg-open "$1"', desc = "Open", for = "linux" },
    ]

    [open]
    prepend_rules = [
      { mime = "text/*", use = "edit" },
      { mime = "application/json", use = "edit" },
      { mime = "application/x-shellscript", use = "edit" },
    ]
  '';

  xdg.configFile."yazi/theme.toml".text = ''
    [manager]
    cwd = { fg = "#${c.base0E}", bold = true }
    hovered = { fg = "#${c.base00}", bg = "#${c.base0E}", bold = true }
    preview_hovered = { fg = "#${c.base00}", bg = "#${c.base0D}", bold = true }
    find_keyword = { fg = "#${c.base0A}", bold = true, italic = true }
    find_position = { fg = "#${c.base09}", bg = "#${c.base02}", bold = true }
    marker_selected = { fg = "#${c.base0B}", bg = "#${c.base0B}" }
    marker_copied = { fg = "#${c.base0A}", bg = "#${c.base0A}" }
    marker_cut = { fg = "#${c.base08}", bg = "#${c.base08}" }
    tab_active = { fg = "#${c.base00}", bg = "#${c.base0E}", bold = true }
    tab_inactive = { fg = "#${c.base05}", bg = "#${c.base02}" }
    border_symbol = "│"
    border_style = { fg = "#${c.base03}" }

    [status]
    separator_open = ""
    separator_close = ""
    separator_style = { fg = "#${c.base03}", bg = "#${c.base02}" }
    mode_normal = { fg = "#${c.base00}", bg = "#${c.base0D}", bold = true }
    mode_select = { fg = "#${c.base00}", bg = "#${c.base0B}", bold = true }
    mode_unset = { fg = "#${c.base00}", bg = "#${c.base08}", bold = true }
    progress_label = { fg = "#${c.base05}", bold = true }
    progress_normal = { fg = "#${c.base0E}", bg = "#${c.base02}" }
    progress_error = { fg = "#${c.base08}", bg = "#${c.base02}" }
    permissions_t = { fg = "#${c.base0D}" }
    permissions_r = { fg = "#${c.base0A}" }
    permissions_w = { fg = "#${c.base08}" }
    permissions_x = { fg = "#${c.base0B}" }
    permissions_s = { fg = "#${c.base03}" }

    [select]
    border = { fg = "#${c.base0E}" }
    active = { fg = "#${c.base0E}", bold = true }
    inactive = { fg = "#${c.base05}" }

    [input]
    border = { fg = "#${c.base0E}" }
    title = { fg = "#${c.base0E}", bold = true }
    value = { fg = "#${c.base05}" }
    selected = { fg = "#${c.base00}", bg = "#${c.base0E}" }

    [completion]
    border = { fg = "#${c.base0D}" }
    active = { fg = "#${c.base00}", bg = "#${c.base0D}", bold = true }
    inactive = { fg = "#${c.base05}" }

    [tasks]
    border = { fg = "#${c.base0D}" }
    title = { fg = "#${c.base0D}", bold = true }
    hovered = { fg = "#${c.base00}", bg = "#${c.base0D}" }

    [which]
    mask = { bg = "#${c.base01}" }
    cand = { fg = "#${c.base0E}", bold = true }
    rest = { fg = "#${c.base03}" }
    desc = { fg = "#${c.base0D}" }
    separator = " 󰁔 "
    separator_style = { fg = "#${c.base03}" }

    [help]
    on = { fg = "#${c.base0E}", bold = true }
    run = { fg = "#${c.base0C}" }
    desc = { fg = "#${c.base05}" }
    hovered = { fg = "#${c.base00}", bg = "#${c.base0E}", bold = true }
    footer = { fg = "#${c.base03}" }

    [filetype]
    rules = [
      { mime = "image/*", fg = "#${c.base0A}" },
      { mime = "video/*", fg = "#${c.base09}" },
      { mime = "audio/*", fg = "#${c.base09}" },
      { mime = "application/zip", fg = "#${c.base08}" },
      { mime = "application/gzip", fg = "#${c.base08}" },
      { mime = "application/x-tar", fg = "#${c.base08}" },
      { mime = "inode/x-empty", fg = "#${c.base03}" },
      { name = "*", is = "orphan", fg = "#${c.base08}" },
      { name = "*", is = "exec", fg = "#${c.base0B}" },
      { name = "*/", fg = "#${c.base0E}", bold = true },
    ]
  '';
}
