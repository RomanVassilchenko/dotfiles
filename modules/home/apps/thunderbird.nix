{ pkgs, ... }:
{
  # Thunderbird - Email client
  home.packages = [ pkgs.thunderbird ];

  # Autostart - opens on Desktop 4 (configured via KWin window rules)
  xdg.configFile."autostart/thunderbird.desktop".text = ''
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
}
