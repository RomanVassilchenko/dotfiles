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
  paletteKeys = [
    "base00"
    "base02"
    "base03"
    "base05"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
  ];
  procsColors = map (name: "#${c.${name}}") paletteKeys;
  procsTemplate = builtins.readFile ./procs/config.toml;
  procsConfig = builtins.replaceStrings (map (
    name: "@@" + name + "@@"
  ) paletteKeys) procsColors procsTemplate;
in
{
  xdg.configFile."procs/config.toml".text = procsConfig;
}
