{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    insync
    libreoffice
    obsidian
  ];
}
