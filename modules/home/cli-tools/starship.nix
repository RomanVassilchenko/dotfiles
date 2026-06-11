{
  pkgs-stable,
  lib,
  config,
  ...
}:
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
  osSymbols = import ./starship/os-symbols.nix;
in
{
  programs.starship = {
    enable = true;
    package = pkgs-stable.starship;
    settings = import ./starship/settings.nix {
      inherit c lib osSymbols;
    };
  };
}
