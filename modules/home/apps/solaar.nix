{
  dotfiles,
  pkgs,
  lib,
  appConfig,
  ...
}:
lib.mkIf dotfiles.features.apps.solaar.enable {
  xdg.configFile."autostart/solaar.desktop" = lib.mkIf (appConfig.solaar.autostart or false) {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Solaar
      Comment=Logitech Unifying Receiver peripherals manager
      Exec=${pkgs.solaar}/bin/solaar --window=hide
      Icon=solaar
      Terminal=false
      Categories=Utility;GTK;
    '';
  };
}
