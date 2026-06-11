{
  dotfiles,
  lib,
  ...
}:
let
  widgets = import ./panel-widgets.nix;
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma = {
    startup.desktopScript.panels.runAlways = true;

    panels = [
      {
        location = "top";
        height = 30;
        floating = false;
        hiding = "none";
        opacity = "opaque";
        widgets = widgets;
      }
    ];
  };
}
