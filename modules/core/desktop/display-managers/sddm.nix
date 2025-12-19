{ pkgs, ... }:
let
  # Catppuccin SDDM theme with Mocha flavor and Mauve accent
  catppuccin-sddm-theme = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    font = "Inter";
    fontSize = "11";
    background = "${../../../../wallpapers/kurzgesagt-galaxies.jpg}";
    loginBackground = true;
  };
in
{
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
      extraPackages = [ catppuccin-sddm-theme ];

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
        };
      };
    };
  };

  environment.systemPackages = [
    catppuccin-sddm-theme
    pkgs.bibata-cursors
  ];
}
