{ pkgs, lib, ... }:
let
  # Catppuccin SDDM theme with Mocha flavor
  catppuccin-sddm-theme = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    font = "Inter";
    fontSize = "11";
    background = "${../../../../wallpapers/kurzgesagt-galaxies.jpg}";
    loginBackground = true;
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtmultimedia
      qtvirtualkeyboard
      qt5compat
    ];

    settings = {
      General = {
        DisplayServer = "wayland";
      };
      Wayland = {
        EnableHiDPI = true;
        SessionDir = "${pkgs.kdePackages.plasma-workspace}/share/wayland-sessions";
      };
      X11 = {
        EnableHiDPI = true;
      };
      Theme = {
        CursorTheme = "Bibata-Modern-Ice";
        CursorSize = 24;
        Font = "Inter,11";
        ThemeDir = "${catppuccin-sddm-theme}/share/sddm/themes";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    catppuccin-sddm-theme
    bibata-cursors
  ];
}
