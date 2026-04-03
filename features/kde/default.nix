{
  config,
  lib,
  ...
}:
let
  cfg = config.features.kde;
in
{
  options.features.kde.enable = lib.mkEnableOption "KDE Plasma feature bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.desktop.enable = true;
    dotfiles.features.desktop.plasma.enable = true;
  };
}
