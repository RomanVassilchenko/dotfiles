{
  pkgs,
  lib,
  config,
  isServer,
  ...
}:
{
  config = lib.mkIf isServer {
    # Cloudflared tunnel token secret
    age.secrets.cloudflared-tunnel-token = {
      file = ../../../secrets/cloudflared-tunnel-token.age;
      mode = "400";
    };

    # Cloudflared tunnel service (token-based, dashboard-managed)
    systemd.services.cloudflared-tunnel = {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file %d/token";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
        LoadCredential = "token:${config.age.secrets.cloudflared-tunnel-token.path}";
      };
    };
  };
}
