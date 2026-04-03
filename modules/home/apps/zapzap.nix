{
  dotfiles,
  pkgs,
  lib,
  appConfig,
  ...
}:
lib.mkIf dotfiles.features.apps.zapzap.enable {
  xdg.configFile."autostart/com.rtosta.zapzap.desktop" =
    lib.mkIf (appConfig.zapzap.autostart or false)
      {
        text = ''
          [Desktop Entry]
          Type=Application
          Name=ZapZap
          Comment=WhatsApp desktop application
          Exec=${pkgs.zapzap}/bin/zapzap
          Icon=com.rtosta.zapzap
          Terminal=false
          Categories=Network;InstantMessaging;
          StartupWMClass=zapzap
        '';
      };
}
