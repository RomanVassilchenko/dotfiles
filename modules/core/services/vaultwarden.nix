{
  lib,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";
in
{
  config = lib.mkIf isServer {
    services.vaultwarden = {
      enable = true;
      backupDir = "/var/backup/vaultwarden";
      config = {
        DOMAIN = "https://bitwarden.romanv.dev";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
        # Web vault enabled by default
        WEB_VAULT_ENABLED = true;
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ 8222 ];
  };
}
