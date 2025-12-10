{ pkgs, ... }:
{
  # Bitwarden - Password manager
  home.packages = [ pkgs.bitwarden-desktop ];

  # Autostart
  # Note: Starts with window visible (no CLI flag for tray). Configure via File > Settings > "Start to tray icon"
  xdg.configFile."autostart/bitwarden.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Categories=Utility
    Name=Bitwarden
    Comment=Secure and free password manager for all of your devices
    Exec=${pkgs.bitwarden-desktop}/bin/bitwarden %U
    Icon=bitwarden
    MimeType=x-scheme-handler/bitwarden
    Version=1.5
  '';
}
