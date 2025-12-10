{ pkgs, lib, appConfig, ... }:
{
  # Brave - Web browser
  home.packages = [ pkgs.brave ];

  # Autostart - opens on Desktop 1 (configured via KWin window rules)
  xdg.configFile."autostart/brave-browser.desktop" = lib.mkIf appConfig.brave.autostart {
    text = ''
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
  };
}
