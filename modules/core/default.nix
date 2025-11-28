{ inputs, ... }:
{
  imports = [
    # Core system configuration
    ./system/boot.nix
    ./system/hardware.nix
    ./system/network.nix
    ./system/security.nix
    ./system/system.nix
    ./system/user.nix
    ./system/virtualisation.nix

    # Security
    ./security/agenix.nix

    # System tools
    ./tools/nh.nix
    ./tools/packages.nix

    # Core services (pipewire, blueman, keyring, etc.)
    ./services.nix

    # Services
    ./services/printing.nix
    ./services/syncthing.nix
    ./services/vpn.nix

    # Desktop apps
    ./desktop/apps/flatpak.nix
    ./desktop/apps/fonts.nix
    ./desktop/apps/steam.nix

    # Desktop environments
    ./desktop/environments/xserver.nix
    ./desktop/environments/plasma.nix
    ./desktop/display-managers/sddm.nix

    # Development packages
    ./packages/development/golang.nix
    ./packages/development/protobuf.nix
    ./packages/development/databases.nix
    ./packages/development/development.nix

    # Desktop packages
    ./packages/desktop/desktop-apps.nix
    ./packages/desktop/gaming.nix
    ./packages/desktop/media-graphics.nix

    # CLI packages
    ./packages/cli/cli-tools.nix
    ./packages/cli/system-monitoring.nix
    ./packages/cli/file-management.nix
    ./packages/cli/network-tools.nix
  ];
}
