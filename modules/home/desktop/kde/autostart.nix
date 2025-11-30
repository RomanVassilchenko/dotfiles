{ pkgs, ... }:
{
  # KDE autostart applications
  # These apps will start automatically when KDE Plasma session begins
  xdg.configFile = {
    # Bitwarden - Password manager
    # Note: Starts with window visible (no CLI flag for tray). Configure via File > Settings > "Start to tray icon"
    "autostart/bitwarden.desktop".text = ''
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

    # Telegram - Messaging app, starts minimized to tray on Desktop 3
    "autostart/org.telegram.desktop.desktop".text = ''
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

    # Brave browser - Opens on Desktop 1 (configured via KWin window rules)
    "autostart/brave-browser.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Brave Web Browser
      Comment=Access the Internet
      Exec=${pkgs.brave}/bin/brave %U
      Icon=brave-browser
      Terminal=false
      Categories=Network;WebBrowser;
      MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
      StartupWMClass=brave-browser
    '';

    # ZapZap - WhatsApp client (Flatpak)
    # Note: No CLI flag for tray start. May need to configure via app settings or KWin window rules
    "autostart/com.rtosta.zapzap.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=ZapZap
      Comment=WhatsApp desktop application
      Exec=flatpak run com.rtosta.zapzap
      Icon=com.rtosta.zapzap
      Terminal=false
      Categories=Network;InstantMessaging;
      StartupWMClass=zapzap
    '';

    # Solaar - Logitech device manager, starts hidden in tray
    "autostart/solaar.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Solaar
      Comment=Logitech Unifying Receiver peripherals manager
      Exec=${pkgs.solaar}/bin/solaar --window=hide
      Icon=solaar
      Terminal=false
      Categories=Utility;GTK;
    '';

    # Joplin - Note-taking app
    # Note: No CLI flag for tray start. Configure via Tools > Options > Application > "Start application minimised in the tray icon"
    "autostart/joplin.desktop".text = ''
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

    # Thunderbird - Email client, opens on Desktop 4 (configured via KWin window rules)
    "autostart/thunderbird.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Thunderbird
      Comment=Email, RSS and newsgroup client
      Exec=${pkgs.thunderbird}/bin/thunderbird
      Icon=thunderbird
      Terminal=false
      Categories=Network;Email;
      MimeType=x-scheme-handler/mailto;application/x-xpinstall;
      StartupWMClass=thunderbird
    '';

    # Zoom - Video conferencing, opens on Desktop 5 (configured via KWin window rules)
    "autostart/zoom.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Zoom
      Comment=Zoom Video Conference
      Exec=${pkgs.zoom-us}/bin/zoom
      Icon=Zoom
      Terminal=false
      Categories=Network;VideoConference;
      StartupWMClass=zoom
    '';

  };
}
