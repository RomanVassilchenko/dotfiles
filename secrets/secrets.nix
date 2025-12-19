# Agenix secrets configuration
# This file defines which SSH public keys can decrypt which secrets
#
# Usage:
#   - Edit secrets: agenix -e secrets/<name>.age
#   - Rekey all secrets after adding a new key: agenix -r
#
# Documentation: https://github.com/ryantm/agenix
let
  # User SSH keys (can decrypt secrets on their respective machines)
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInNKbTTbxK433xEXs5A3az+j7z9bBxdgPQn6BhiOgnq";
  xiaoxinpro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAcIlwANtn26rwkJfUfZKMSfGScbtKIUSBOR4iIl3EV";

  # Server SSH host keys (for secrets needed by servers)
  ninkear = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAskiNEKBGA7/nnqCzo+Reo+yA2zdRCGLze1mRrTK74u";

  # All user keys (for secrets that should be accessible from any machine)
  allUsers = [
    personal
    xiaoxinpro
  ];

  # Server keys for server-specific secrets
  serverKeys = [ ninkear ];
in
{
  # Work-related secrets
  "work-email.age".publicKeys = allUsers;

  # SSH configuration secrets
  "ssh-host-home-ip.age".publicKeys = allUsers;
  "ssh-host-aq-ip.age".publicKeys = allUsers;
  "ssh-aq-username.age".publicKeys = allUsers;
  "bereke-gitlab-hostname.age".publicKeys = allUsers;

  # VPN - BerekeBank (OpenConnect)
  "vpn-bereke-gateway.age".publicKeys = allUsers;
  "vpn-bereke-dns.age".publicKeys = allUsers;
  "vpn-bereke-dns-search.age".publicKeys = allUsers;
  "vpn-bereke-username.age".publicKeys = allUsers;
  "vpn-bereke-password.age".publicKeys = allUsers;
  "vpn-bereke-totp-secret.age".publicKeys = allUsers;

  # VPN - Dahua (OpenFortiVPN)
  "vpn-dahua-host.age".publicKeys = allUsers;
  "vpn-dahua-password.age".publicKeys = allUsers;
  "vpn-dahua-cert.age".publicKeys = allUsers;

  # Cloudflare Tunnel (server needs access)
  "cloudflared-tunnel-token.age".publicKeys = allUsers ++ serverKeys;

  # Pi-hole (server needs access)
  "pihole-webpassword.age".publicKeys = allUsers ++ serverKeys;
}
