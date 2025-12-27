# Desktop utilities - only loaded on desktop/laptop (not server)
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    appimage-run
    droidcam
    xdg-utils
  ];
}
