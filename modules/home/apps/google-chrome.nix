{
  pkgs,
  lib,
  appConfig,
  ...
}:
{
  home.packages = [ pkgs.google-chrome ];

  xdg.configFile."autostart/google-chrome.desktop" = lib.mkIf appConfig.google-chrome.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Google Chrome
      Comment=Access the Internet
      Exec=${pkgs.google-chrome}/bin/google-chrome-stable %U
      Icon=google-chrome
      Terminal=false
      Categories=Network;WebBrowser;
      MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
      StartupWMClass=google-chrome
    '';
  };
}
