{ pkgs, ... }:
{
  # GUI applications - only loaded on desktop/laptop (not server)
  environment.systemPackages = with pkgs; [
    brave
    discord
    droidcam
    telegram-desktop
    zoom-us
    libreoffice
    joplin-desktop
    bitwarden-desktop
    camunda-modeler
    solaar
    thunderbird
    xdg-utils
    appimage-run
  ];
}
