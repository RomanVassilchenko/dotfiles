{ pkgs, lib, appConfig, ... }:
{
  # Zoom - Video conferencing
  home.packages = [ pkgs.zoom-us ];

  # Autostart - opens on Desktop 5 (configured via KWin window rules)
  xdg.configFile."autostart/zoom.desktop" = lib.mkIf appConfig.zoom.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Zoom
      Comment=Zoom Video Conference
      Exec=${pkgs.zoom-us}/bin/zoom
      Icon=Zoom
      Terminal=false
      Categories=Network;VideoConference;
      StartupWMClass=zoom
    '';
  };
}
