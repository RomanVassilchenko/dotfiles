{
  pkgs,
  lib,
  appConfig,
  ...
}:
{
  # Telegram - Messaging app
  home.packages = [ pkgs.telegram-desktop ];

  # Autostart - starts minimized to tray on Desktop 3
  xdg.configFile."autostart/org.telegram.desktop.desktop" = lib.mkIf appConfig.telegram.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Telegram
      Comment=New era of messaging
      Exec=${pkgs.telegram-desktop}/bin/Telegram -autostart
      Icon=org.telegram.desktop
      Terminal=false
      StartupWMClass=TelegramDesktop
      Categories=Chat;Network;InstantMessaging;Qt;
      MimeType=x-scheme-handler/tg;x-scheme-handler/tonsite;
      Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
      SingleMainWindow=true
      X-GNOME-UsesNotifications=true
    '';
  };
}
