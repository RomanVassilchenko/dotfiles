{ lib, config, ... }:
let
  # Map Stylix base16 slots to the named colors used in starship.toml.
  # builtins.readFile preserves Unicode powerline glyphs — nixfmt never touches
  # file contents, only Nix string literals. The palette is appended dynamically
  # so colors follow the system Stylix theme automatically.
  c = config.lib.stylix.colors;
  palette = ''

    [palettes.stylix]
    mauve   = "#${c.base0E}"
    blue    = "#${c.base0D}"
    yellow  = "#${c.base0A}"
    green   = "#${c.base0B}"
    teal    = "#${c.base0C}"
    red     = "#${c.base08}"
    peach   = "#${c.base09}"
    crust   = "#${c.base00}"
    text    = "#${c.base05}"
    overlay0 = "#${c.base03}"
    surface0 = "#${c.base02}"
  '';
in
{
  programs.starship = {
    enable = true;
    settings = lib.mkForce { };
  };

  xdg.configFile."starship.toml" = lib.mkForce {
    text = builtins.readFile ./starship.toml + palette;
  };
}
