{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  config = lib.mkIf isServer {
    # Joplin Server via Docker containers
    # No native NixOS module exists, using OCI containers
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        joplin-db = {
          image = "postgres:16";
          environment = {
            POSTGRES_USER = "joplin";
            POSTGRES_PASSWORD = "joplin";
            POSTGRES_DB = "joplin";
          };
          volumes = [
            "joplin-db:/var/lib/postgresql/data"
          ];
          extraOptions = [ "--network=joplin-network" ];
        };

        joplin-server = {
          image = "joplin/server:latest";
          dependsOn = [ "joplin-db" ];
          environment = {
            APP_PORT = "22300";
            APP_BASE_URL = "https://joplin.romanv.dev";
            MAILER_ENABLED = "0";
            DB_CLIENT = "pg";
            POSTGRES_HOST = "joplin-db";
            POSTGRES_PORT = "5432";
            POSTGRES_USER = "joplin";
            POSTGRES_PASSWORD = "joplin";
            POSTGRES_DATABASE = "joplin";
          };
          ports = [ "22300:22300" ];
          extraOptions = [ "--network=joplin-network" ];
        };
      };
    };

    # Create Docker network for Joplin
    systemd.services.joplin-network = {
      description = "Create Docker network for Joplin";
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.docker}/bin/docker network create joplin-network || true
      '';
      preStop = ''
        ${pkgs.docker}/bin/docker network rm joplin-network || true
      '';
    };

    # Ensure containers start after network
    systemd.services.docker-joplin-db.after = [ "joplin-network.service" ];
    systemd.services.docker-joplin-server.after = [ "joplin-network.service" ];

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ 22300 ];
  };
}
