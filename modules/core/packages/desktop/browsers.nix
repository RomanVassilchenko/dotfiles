{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages = with pkgs; [
    brave
    google-chrome
  ];
}
