{
  pkgs,
  lib,
  appConfig,
  ...
}:
{
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
