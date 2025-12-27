# Services configuration
# Common services for all, desktop/server specific conditionally imported
{
  lib,
  isServer,
  ...
}:
{
  imports =
    [
      # Common services (all systems)
      ./common.nix
      ./firewall.nix
      ./performance.nix
      ./headscale.nix # Has both server (headscale) and client (tailscale) parts
      ./vpn.nix
    ]
    ++ lib.optionals (!isServer) [
      # Desktop-only services
      ./desktop.nix
      ./printing.nix
      ./kdeconnect.nix
    ]
    ++ lib.optionals isServer [
      # Server-only services
      ./fail2ban.nix
      ./server
    ];
}
