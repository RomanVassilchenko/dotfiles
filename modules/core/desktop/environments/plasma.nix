{ pkgs, ... }:
{
  # Enable KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # KDE Plasma environment packages
  environment.systemPackages =
    (with pkgs.kdePackages; [
      # Core Plasma packages
      plasma-desktop
      plasma-workspace
      plasma-workspace-wallpapers

      # KDE applications
      dolphin # File manager
      ark # Archive manager
      okular # Document viewer
      gwenview # Image viewer
      spectacle # Screenshot tool
      kdeconnect-kde # Phone integration
      kcalc # Calculator
      partitionmanager # Partition manager
      krdc # Remote desktop client
      filelight # Disk usage analyzer

      # Plasma widgets and utilities
      plasma-browser-integration
      plasma-pa # PulseAudio integration
      plasma-nm # NetworkManager integration
      kscreen # Screen management

      # System settings and configuration
      systemsettings

      # Additional utilities
      kwalletmanager
      kwallet
      kwallet-pam
    ])
    ++ (with pkgs; [
      # Icon themes
      papirus-icon-theme

      # Media players
      haruna # Video player
    ]);

  # Enable KWallet PAM integration
  security.pam.services.sddm.enableKwallet = true;
  security.pam.services.login.enableKwallet = true;

  # Enable power management
  services.power-profiles-daemon.enable = true;

  # Exclude some default KDE applications we don't need
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    khelpcenter # KDE Help Center
    konsole # Terminal
    discover # App store (using nh/nix instead)
  ];

  systemd.user.services = {
    "app-org.kde.discover.notifier@autostart".enable = false;
  };
}
