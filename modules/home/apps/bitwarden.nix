{
  dotfiles,
  pkgs-stable,
  lib,
  appConfig,
  ...
}:
let
  bitwardenPackage = pkgs-stable.bitwarden-desktop;
in
lib.mkIf dotfiles.features.apps.bitwarden.enable {
  xdg.configFile."autostart/bitwarden.desktop" = lib.mkIf (appConfig.bitwarden.autostart or false) {
    text = ''
      [Desktop Entry]
      Type=Application
      Categories=Utility
      Name=Bitwarden
      Comment=Secure and free password manager for all of your devices
      Exec=${bitwardenPackage}/bin/bitwarden %U
      Icon=bitwarden
      MimeType=x-scheme-handler/bitwarden
      Version=1.5
    '';
  };
}
