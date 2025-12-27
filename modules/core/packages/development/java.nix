# Java development - desktop only
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jdk
  ];
}
