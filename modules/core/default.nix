{
  inputs,
  lib,
  isServer,
  ...
}:
{
  imports = [
    # Core system configuration (always loaded)
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

    # Core services (pipewire, blueman, keyring, etc. - conditional for server)
    ./services.nix

    # Services
    ./services/printing.nix
    ./services/vpn.nix
    ./services/fail2ban.nix
    ./services/firewall.nix
    ./services/performance.nix
    ./services/kdeconnect.nix
    ./services/joplin-server.nix
    ./services/vaultwarden.nix
    ./services/cloudflared.nix
    ./services/pihole.nix
    ./services/samba.nix
    ./services/harmonia.nix
    ./services/weekly-update.nix
    ./services/weekly-cleanup.nix

    # Development packages (always loaded)
    ./packages/development/golang.nix
    ./packages/development/protobuf.nix
    ./packages/development/databases.nix
    ./packages/development/development.nix

    # CLI packages (always loaded)
    ./packages/cli/cli-tools.nix
    ./packages/cli/system-monitoring.nix
    ./packages/cli/file-management.nix
    ./packages/cli/network-tools.nix
  ]
  ++ lib.optionals (!isServer) [
    # Theming (laptop/desktop only)
    ./desktop/stylix.nix

    # Desktop apps (laptop/desktop only)
    ./desktop/apps/flatpak.nix
    ./desktop/apps/fonts.nix
    ./desktop/apps/steam.nix

    # Desktop environments (laptop/desktop only)
    ./desktop/environments/xserver.nix
    ./desktop/environments/plasma.nix
    ./desktop/environments/plasma-xdg-fix.nix
    ./desktop/display-managers/sddm.nix

    # Desktop packages (laptop/desktop only)
    ./packages/desktop/desktop-apps.nix
    ./packages/desktop/gaming.nix
    ./packages/desktop/media-graphics.nix
  ];
}
