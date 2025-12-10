{ pkgs, lib, appConfig, ... }:
{
  # Joplin - Note-taking app
  home.packages = [ pkgs.joplin-desktop ];

  # Autostart
  # Note: No CLI flag for tray start. Configure via Tools > Options > Application > "Start application minimised in the tray icon"
  xdg.configFile."autostart/joplin.desktop" = lib.mkIf appConfig.joplin.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Joplin
      Comment=Joplin - an open source note taking and to-do application
      Exec=${pkgs.joplin-desktop}/bin/joplin-desktop
      Icon=joplin
      Terminal=false
      Categories=Office;
      MimeType=x-scheme-handler/joplin;
      StartupWMClass=Joplin
    '';
  };
}
