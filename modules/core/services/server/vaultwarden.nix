# Vaultwarden - Bitwarden-compatible password manager server
{ ... }:
{
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      DOMAIN = "https://bitwarden.romanv.dev";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      WEB_VAULT_ENABLED = true;
    };
  };

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8222 ];
}
