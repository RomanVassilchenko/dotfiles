{
  dotfiles,
  pkgs,
  lib,
  appConfig,
  ...
}:
lib.mkIf dotfiles.features.apps.thunderbird.enable {
  xdg.configFile."autostart/birdtray.desktop" = lib.mkIf (appConfig.thunderbird.autostart or false) {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Birdtray
      Comment=System tray new mail notification for Thunderbird
      Exec=${pkgs.birdtray}/bin/birdtray
      Icon=birdtray
      Terminal=false
      Categories=Network;Email;
      StartupWMClass=birdtray
    '';
  };
}
