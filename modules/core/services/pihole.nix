{
  pkgs,
  lib,
  config,
  isServer,
  ...
}:
{
  config = lib.mkIf isServer {
    # Pi-hole web password secret
    age.secrets.pihole-webpassword = {
      file = ../../../secrets/pihole-webpassword.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };

    # Generate Pi-hole env file with secret password
    systemd.services.pihole-env-generator = {
      description = "Generate Pi-hole environment file with secrets";
      after = [ "agenix.service" ];
      before = [ "docker-pihole.service" ];
      requiredBy = [ "docker-pihole.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /run/pihole
        echo "WEBPASSWORD=$(cat ${config.age.secrets.pihole-webpassword.path})" > /run/pihole/env
        chmod 0400 /run/pihole/env
      '';
    };

    # Pi-hole DNS server via Docker container
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        pihole = {
          image = "pihole/pihole:latest";
          environmentFiles = [ "/run/pihole/env" ];
          environment = {
            TZ = "Asia/Almaty";
            # Upstream DNS: Cloudflare primary, Google fallback
            PIHOLE_DNS_ = "1.1.1.1;1.0.0.1;8.8.8.8;8.8.4.4";
            DNSSEC = "true";
            REV_SERVER = "true";
            REV_SERVER_DOMAIN = "local";
            REV_SERVER_TARGET = "192.168.1.1";
            REV_SERVER_CIDR = "192.168.1.0/24";
            # Allow queries from LAN
            DNSMASQ_LISTENING = "all";
          };
          ports = [
            "53:53/tcp"
            "53:53/udp"
            "8053:80/tcp" # Web interface on port 8053
          ];
          volumes = [
            "pihole-etc:/etc/pihole"
            "pihole-dnsmasq:/etc/dnsmasq.d"
          ];
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--dns=127.0.0.1"
            "--dns=1.1.1.1"
            "--hostname=pihole"
          ];
        };
      };
    };

    # Local DNS entries for services
    # These will be added to Pi-hole's custom DNS
    environment.etc."pihole-custom-dns.list" = {
      text = ''
        192.168.1.80 bitwarden.local
        192.168.1.80 joplin.local
        192.168.1.80 pihole.local
        192.168.1.80 ninkear.local
      '';
      mode = "0644";
    };

    # Service to copy custom DNS entries to Pi-hole volume
    systemd.services.pihole-custom-dns = {
      description = "Configure Pi-hole custom DNS entries";
      after = [ "docker-pihole.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Wait for Pi-hole container to be ready
        sleep 10

        # Copy custom DNS list to Pi-hole volume
        ${pkgs.docker}/bin/docker cp /etc/pihole-custom-dns.list pihole:/etc/pihole/custom.list || true

        # Restart DNS to apply changes
        ${pkgs.docker}/bin/docker exec pihole pihole restartdns || true
      '';
    };

    # Open firewall ports for DNS
    networking.firewall = {
      allowedTCPPorts = [
        53    # DNS
        8053  # Pi-hole web interface
      ];
      allowedUDPPorts = [
        53 # DNS
      ];
    };

    # Disable systemd-resolved to avoid port 53 conflict
    services.resolved.enable = false;
  };
}
