{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./config.nix
    ./panels.nix
    ./wallpaper.nix
    ./widgets.nix
  ];

  home.packages = with pkgs; [
    # KWin plugins
    kde-rounded-corners
    kdePackages.krohnkite
    kdotool
    libnotify

    # Catppuccin theme packages
    bibata-cursors # Modern white cursor (Bibata-Modern-Ice)
    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "mauve" ];
    })

    # KDE utilities
    kdePackages.kcalc

    # Plasma Manager utilities
    inputs.plasma-manager.packages.${pkgs.stdenv.hostPlatform.system}.rc2nix
  ];

  # Apply Catppuccin Mocha color scheme
  programs.plasma.workspace.colorScheme = "CatppuccinMochaMauve";

  # GTK theme integration for consistency
  # Use mkForce to override Stylix's defaults with Catppuccin Mauve accent
  gtk = {
    enable = true;
    theme = {
      name = lib.mkForce "catppuccin-mocha-mauve-standard";
      package = lib.mkForce (
        pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "mauve" ];
        }
      );
    };
    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      package = lib.mkForce (
        pkgs.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "mauve";
        }
      );
    };
  };

  # Qt theme to match
  # Use mkForce to override Stylix's defaults
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde";
    style.name = lib.mkForce "kvantum";
  };

  # Kvantum theme for Qt apps
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-mauve
  '';
}
