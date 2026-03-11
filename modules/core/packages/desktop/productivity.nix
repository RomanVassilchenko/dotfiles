{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    insync
    libreoffice
    obsidian
  ];
}
