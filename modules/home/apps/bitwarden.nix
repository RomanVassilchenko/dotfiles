{
  pkgs,
  lib,
  appConfig,
  ...
}:
{
  xdg.configFile."autostart/bitwarden.desktop" = lib.mkIf (appConfig.bitwarden.autostart or false) {
    text = ''
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
  };
}
