{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages =
    (with pkgs-stable; [
      appimage-run
      warp-terminal
      wl-clipboard
      xdg-utils
    ])
    ++ (with pkgs; [
      # Runtime and helper libraries for external NCALayer installs in ~/NCALayer.
      atk
      cairo
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk2
      libx11
      libxext
      libxi
      libxrender
      libxtst
      nssTools
      pango
      pcsc-tools
      pcsclite
    ]);
}
