{ ... }:
{
  # ZapZap - WhatsApp client (Flatpak)
  # Package installed via flatpak in modules/core/desktop/apps/flatpak.nix
  # Note: No CLI flag for tray start. May need to configure via app settings or KWin window rules
  xdg.configFile."autostart/com.rtosta.zapzap.desktop".text = ''
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
}
