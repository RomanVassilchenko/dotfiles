# Agenix secrets configuration
# This file defines which SSH public keys can decrypt which secrets
#
# Usage:
#   - Edit secrets: agenix -e secrets/<name>.age
#   - Rekey all secrets after adding a new key: agenix -r
#
# Documentation: https://github.com/ryantm/agenix
let
  # User SSH key (same key used across all systems)
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInNKbTTbxK433xEXs5A3az+j7z9bBxdgPQn6BhiOgnq";

  # All keys (accessible from any machine including servers)
  allKeys = [ personal ];
in
{
  # Work-related secrets
  "work-email.age".publicKeys = allKeys;

  # SSH configuration secrets
  "ssh-host-home-ip.age".publicKeys = allKeys;
  "ssh-host-aq-ip.age".publicKeys = allKeys;
  "ssh-aq-username.age".publicKeys = allKeys;
  "bereke-gitlab-hostname.age".publicKeys = allKeys;

  # VPN - BerekeBank (OpenConnect)
  "vpn-bereke-gateway.age".publicKeys = allKeys;
  "vpn-bereke-dns.age".publicKeys = allKeys;
  "vpn-bereke-dns-search.age".publicKeys = allKeys;
  "vpn-bereke-username.age".publicKeys = allKeys;
  "vpn-bereke-password.age".publicKeys = allKeys;
  "vpn-bereke-totp-secret.age".publicKeys = allKeys;

  # VPN - Dahua (OpenFortiVPN)
  "vpn-dahua-host.age".publicKeys = allKeys;
  "vpn-dahua-password.age".publicKeys = allKeys;
  "vpn-dahua-cert.age".publicKeys = allKeys;

  # Cloudflare Tunnel
  "cloudflared-tunnel-token.age".publicKeys = allKeys;
}
