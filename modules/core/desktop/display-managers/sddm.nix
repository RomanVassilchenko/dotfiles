{ pkgs, ... }:
{
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;

      # Theme configuration
      theme = "breeze";

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
          Current = "breeze";
          CursorTheme = "Breeze_Light";
          Font = "Inter Variable,11";
          EnableAvatars = true;
          DisableAvatarsThreshold = 7;
        };
      };
    };
  };

  # Create theme configuration override for background
  environment.etc."sddm.conf.d/kde_settings.conf".text = ''
    [Theme]
    Current=breeze
    CursorTheme=Breeze_Light
    Font=Inter Variable,11
    ThemeDir=/run/current-system/sw/share/sddm/themes
  '';

  # Configure Breeze theme background
  # Uses custom wallpaper from dotfiles
  environment.etc."sddm/themes/breeze/theme.conf.user".text = ''
    [General]
    background=/home/romanv/Documents/dotfiles/wallpapers/kurzgesagt-galaxies.jpg
    type=image
  '';

  # Ensure SDDM theme and configuration packages are installed
  environment.systemPackages = with pkgs; [
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.sddm-kcm # KDE System Settings module for SDDM configuration
    kdePackages.plasma-workspace-wallpapers # Additional KDE wallpapers
  ];
}
