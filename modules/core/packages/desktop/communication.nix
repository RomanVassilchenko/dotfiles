{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vesktop
    telegram-desktop
    zapzap
  ];
}
