{
  config,
  pkgs,
  pkgs-stable,
  lib,
  ...
}:
let
  inherit (config.dotfiles.locale) keyboardLayout;
in
lib.mkIf config.dotfiles.features.desktop.plasma.enable {
  services = {
    desktopManager.plasma6.enable = true;
    greetd.enable = true;

    xserver.xkb = {
      layout = keyboardLayout;
      variant = "";
    };
  };

  programs.regreet = {
    enable = true;
    settings = {
      GTK.cursor_theme_name = "Bibata-Modern-Ice";
      regreet.session_dirs = [ "/run/current-system/sw/share/wayland-sessions" ];
    };
  };

  stylix.targets.regreet = {
    image.enable = false;
    extraCss = ''
      window.background {
        background-color: #000000;
        background-image: none;
      }
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    configPackages = [ pkgs.kdePackages.plasma-desktop ];
  };

  environment.systemPackages =
    (with pkgs.kdePackages; [
      ark
      dolphin
      elisa
      gwenview
      kamoso
      kate
      kcalc
      kcolorchooser
      kdeconnect-kde
      krohnkite
      kscreen
      kwallet
      kwallet-pam
      kwalletmanager
      okular
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
    krdp
    kwin-x11
  ];

  systemd.user.services = {
    "app-org.kde.discover.notifier@autostart".enable = false;
  };

  users.users.greeter.extraGroups = [ "input" ];

}
