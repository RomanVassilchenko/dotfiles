{
  config,
  lib,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.plasma.enable {
  programs.kdeconnect.enable = true;
}
