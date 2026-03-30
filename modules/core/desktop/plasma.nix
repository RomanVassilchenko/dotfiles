{
  pkgs,
  pkgs-stable,
  vars,
  lib,
  ...
}:
let
  inherit (vars) keyboardLayout;
in
{
  services.desktopManager.plasma6.enable = true;

  services.greetd.enable = true;

  programs.regreet = {
    enable = true;
    settings = {
      GTK.cursor_theme_name = "Bibata-Modern-Ice";
      regreet.session_dirs = [ "/run/current-system/sw/share/wayland-sessions" ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    configPackages = [ pkgs.kdePackages.plasma-desktop ];
  };

  services.xserver.xkb = {
    layout = keyboardLayout;
    variant = "";
  };

  environment.systemPackages =
    (with pkgs.kdePackages; [
      ark
      dolphin
      elisa
      filelight
      gwenview
      kamoso
      kate
      kcalc
      kcharselect
      kcolorchooser
      kdeconnect-kde
      krohnkite
      kscreen
      kwallet
      kwallet-pam
      kwalletmanager
      okular
      partitionmanager
      plasma-browser-integration
      plasma-desktop
      plasma-nm
      plasma-pa
      plasma-systemmonitor
      plasma-workspace
      plasma-workspace-wallpapers
      spectacle
      systemsettings
    ])
    ++ (with pkgs-stable; [
      bibata-cursors
      haruna
      kdotool
      libnotify
      python3
    ])
    ++ (with pkgs; [
      plasma-panel-colorizer # keep on unstable — actively developed
      (catppuccin-kde.override {
        flavour = [ "mocha" ];
        accents = [ "mauve" ];
      })
    ]);

  security.pam.services.greetd.enableKwallet = true;
  security.pam.services.login.enableKwallet = true;

  programs.kde-pim.enable = false;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    khelpcenter
    konsole
    krdp
    kwin-x11
  ];

  systemd.user.services = {
    "app-org.kde.discover.notifier@autostart".enable = false;
  };

  users.users.greeter.extraGroups = [ "input" ];

  # Fix for https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
  # Disabled: forces local build (no binary cache hit). Re-enable if XDG_DATA_DIRS issue returns.
  # nixpkgs.overlays = lib.singleton (
  #   final: prev: {
  #     kdePackages = prev.kdePackages // {
  #       plasma-workspace =
  #         let
  #           basePkg = prev.kdePackages.plasma-workspace;
  #
  #           xdgdataPkg = pkgs.stdenv.mkDerivation {
  #             name = "${basePkg.name}-xdgdata";
  #             buildInputs = [ basePkg ];
  #             dontUnpack = true;
  #             dontFixup = true;
  #             dontWrapQtApps = true;
  #             installPhase = ''
  #               mkdir -p $out/share
  #               ( IFS=:
  #                 for DIR in $XDG_DATA_DIRS; do
  #                   if [[ -d "$DIR" ]]; then
  #                     cp -r $DIR/. $out/share/
  #                     chmod -R u+w $out/share
  #                   fi
  #                 done
  #               )
  #             '';
  #           };
  #
  #           derivedPkg = basePkg.overrideAttrs {
  #             postInstall = ''
  #               rm -f $out/share/xsessions/plasmax11.desktop
  #             '';
  #             preFixup = ''
  #               for index in "''${!qtWrapperArgs[@]}"; do
  #                 if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
  #                   unset -v "qtWrapperArgs[$((index+0))]"
  #                   unset -v "qtWrapperArgs[$((index+1))]"
  #                   unset -v "qtWrapperArgs[$((index+2))]"
  #                   unset -v "qtWrapperArgs[$((index+3))]"
  #                 fi
  #               done
  #               qtWrapperArgs=("''${qtWrapperArgs[@]}")
  #               qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
  #               qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
  #             '';
  #           };
  #         in
  #         derivedPkg;
  #     };
  #   }
  # );
}
