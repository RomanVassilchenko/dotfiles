{ pkgs, ... }:
{
  # GUI applications - only loaded on desktop/laptop (not server)
  # Apps with autostart are defined in modules/home/apps/*.nix
  environment.systemPackages = with pkgs; [
    appimage-run
    camunda-modeler
    discord
    droidcam
    google-chrome
    libreoffice
    xdg-utils
  ];
}
