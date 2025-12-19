{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  stylix = lib.mkIf (!isServer) {
    enable = true;

    # Catppuccin Mocha color scheme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Dark theme
    polarity = "dark";

    # Wallpaper (required by Stylix)
    image = ../../../wallpapers/kurzgesagt-galaxies.jpg;

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        desktop = 11;
        popups = 11;
        terminal = 12;
      };
    };

    # Cursor theme
    cursor = {
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "catppuccin-mocha-mauve-cursors";
      size = 24;
    };

    # Opacity settings for blur effect
    opacity = {
      terminal = 0.92;
      popups = 0.95;
    };
  };
}
