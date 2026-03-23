{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages = [
    pkgs-stable.act
    pkgs-stable.android-tools
    pkgs.glab # keep on unstable — actively developed
  ];
}
