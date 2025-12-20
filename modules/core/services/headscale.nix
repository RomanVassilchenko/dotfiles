# Headscale - Self-hosted Tailscale control server
# Runs on ninkear server, provides P2P mesh networking for all devices
{
  pkgs,
  lib,
  config,
  isServer,
  username,
  ...
}:
{
  config = lib.mkMerge [
    # Headscale server (ninkear only)
    (lib.mkIf isServer {
      services.headscale = {
        enable = true;
        address = "127.0.0.1"; # Listen on localhost, Caddy will proxy
        port = 8085;

        settings = {
          server_url = "https://headscale.romanv.dev";

          # Use SQLite for simplicity
          database = {
            type = "sqlite3";
            sqlite.path = "/var/lib/headscale/db.sqlite";
          };

          # IP allocation for the mesh network
          prefixes = {
            v4 = "100.64.0.0/10";
            v6 = "fd7a:115c:a1e0::/48";
          };

          # DERP (relay) configuration
          derp = {
            server = {
              enabled = true;
              region_id = 999;
              region_code = "ninkear";
              region_name = "Ninkear Home";
              stun_listen_addr = "0.0.0.0:3478";
            };
            urls = [ ];
            auto_update_enabled = false;
          };

          # DNS configuration
          dns = {
            magic_dns = true;
            base_domain = "mesh.romanv.dev";
            nameservers.global = [
              "1.1.1.1"
              "8.8.8.8"
            ];
          };

          # Enable direct connections (faster P2P)
          randomize_client_port = false;

          # Logging
          log = {
            level = "info";
          };
        };
      };

      # Caddy reverse proxy for Headscale (handles WebSocket upgrades properly)
      services.caddy = {
        enable = true;
        globalConfig = ''
          auto_https off
        '';
        extraConfig = ''
          :8086 {
            reverse_proxy 127.0.0.1:8085 {
              flush_interval -1
              transport http {
                keepalive off
              }
            }
          }
        '';
      };

      # Open firewall ports for Headscale
      networking.firewall = {
        allowedTCPPorts = [ 8086 ]; # Caddy proxy port
        allowedUDPPorts = [ 3478 ]; # STUN
      };

      # Tailscale client on server (connects to itself)
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "server";
        extraUpFlags = [
          "--login-server=http://127.0.0.1:8085"
          "--accept-routes"
          "--advertise-exit-node"
        ];
      };

      # Systemd override to start Tailscale after Headscale
      systemd.services.tailscaled = {
        after = [ "headscale.service" ];
        wants = [ "headscale.service" ];
      };
    })

    # Tailscale client (all machines)
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkIf (!isServer) "client";
      };

      # Open Tailscale port
      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      # Allow passwordless control of Tailscale
      security.sudo.extraRules = [
        {
          users = [ username ];
          commands = [
            {
              command = "/run/current-system/sw/bin/tailscale *";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      environment.systemPackages = [ pkgs.tailscale ];
    }
  ];
}
