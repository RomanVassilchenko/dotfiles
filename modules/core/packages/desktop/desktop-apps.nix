{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    discord
    droidcam
    telegram-desktop
    zoom-us
    libreoffice
    joplin-desktop
    bitwarden-cli # Bitwarden CLI
    bitwarden-desktop # Bitwarden GUI
    claude-code
    codex
    camunda-modeler
    solaar
    xdg-utils
    distrobox
    docker-compose
    appimage-run
  ];
}
