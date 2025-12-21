{
  ...
}:
{
  imports = [
    ./vpn-manager-tray.nix # Unified VPN manager (Bereke, AQ, Ninkear)
    ./service-monitor.nix
  ];

  # Note: The 'dot' CLI is now a standalone shell script (dot.sh) in the repo root.
  # It is not managed by Nix and should be symlinked to /usr/local/bin/dot via 'dot setup'.
}
