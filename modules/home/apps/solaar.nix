{ pkgs, ... }:
{
  # Solaar - Logitech device manager
  home.packages = [ pkgs.solaar ];

  # Autostart - starts hidden in tray
  xdg.configFile."autostart/solaar.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Solaar
    Comment=Logitech Unifying Receiver peripherals manager
    Exec=${pkgs.solaar}/bin/solaar --window=hide
    Icon=solaar
    Terminal=false
    Categories=Utility;GTK;
  '';
}
