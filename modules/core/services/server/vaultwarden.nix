{ config, lib, ... }:
lib.mkIf config.dotfiles.host.isServer {
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

  networking.firewall.allowedTCPPorts = [ 8222 ];
}
