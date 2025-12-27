# Cloudflared - Tunnel for exposing services
{ pkgs, config, ... }:
{
  # Cloudflared tunnel token secret
  age.secrets.cloudflared-tunnel-token = {
    file = ../../../../secrets/cloudflared-tunnel-token.age;
    mode = "400";
  };

  # Cloudflared tunnel service (token-based, dashboard-managed)
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [
      "network-online.target"
      "agenix.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      exec ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run \
        --token "$(cat "$CREDENTIALS_DIRECTORY/token")"
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      DynamicUser = true;
      LoadCredential = "token:${config.age.secrets.cloudflared-tunnel-token.path}";
    };
  };
}
