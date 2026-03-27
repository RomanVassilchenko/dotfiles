{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    appimage-run
    wl-clipboard
    xdg-utils
  ];
}
