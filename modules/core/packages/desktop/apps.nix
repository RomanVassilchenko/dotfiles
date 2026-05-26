{
  config,
  lib,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages = with pkgs-stable; [
    appimage-run
    warp-terminal
    wl-clipboard
    xdg-utils
  ];
}
