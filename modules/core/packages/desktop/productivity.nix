{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    insync
    libreoffice
    obsidian
  ];
}
