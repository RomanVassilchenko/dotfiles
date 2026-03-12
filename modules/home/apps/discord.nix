{
  pkgs,
  lib,
  appConfig,
  ...
}:
let
  catppuccinMocha = pkgs.fetchurl {
    url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
    sha256 = "sha256-KVv9vfqI+WADn3w4yE1eNsmtm7PQq9ugKiSL3EOLheI=";
  };
in
{
  xdg.configFile."autostart/vesktop.desktop" = lib.mkIf (appConfig.discord.autostart or false) {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Vesktop
      Comment=All-in-one voice and text chat
      Exec=${pkgs.vesktop}/bin/vesktop
      Icon=vesktop
      Terminal=false
      Categories=Network;InstantMessaging;
      StartupWMClass=vesktop
    '';
  };

  xdg.configFile."vesktop/themes/catppuccin-mocha.css".source = catppuccinMocha;
}
