# Server-only services
# Only imported when isServer = true
{ ... }:
{
  imports = [
    ./auto-upgrade.nix
    ./cloudflared.nix
    ./harmonia.nix
    ./joplin-server.nix
    ./samba.nix
    ./vaultwarden.nix
  ];
}
