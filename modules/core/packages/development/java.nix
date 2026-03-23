{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    jdk
  ];
}
