{ pkgs, ... }:
{
  programs.niri.enable = true;

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.niri.default = [ "gtk" ];
  };
}
