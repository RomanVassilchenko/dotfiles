{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    appimage-run
    xdg-utils
  ];
}
