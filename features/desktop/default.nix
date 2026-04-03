{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop;
in
{
  options.features.desktop.enable = lib.mkEnableOption "desktop base feature bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.desktop.enable = true;
  };
}
