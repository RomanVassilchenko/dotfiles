{
  pkgs,
  lib,
  appConfig,
  ...
}:
{
  home.packages = [ pkgs.discord ];

  xdg.configFile."autostart/discord.desktop" = lib.mkIf appConfig.discord.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Discord
      Comment=All-in-one voice and text chat
      Exec=${pkgs.discord}/bin/discord
      Icon=discord
      Terminal=false
      Categories=Network;InstantMessaging;
      StartupWMClass=discord
    '';
  };
}
