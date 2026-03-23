{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    google-chrome
  ];
}
