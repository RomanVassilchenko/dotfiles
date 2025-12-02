{ pkgs, config, ... }:
{
  # Enable OpenConnect support for AnyConnect VPN
  networking.networkmanager = {
    plugins = with pkgs; [
      networkmanager-openconnect
    ];

    # NetworkManager dispatcher scripts for VPN auto-reconnect
    dispatcherScripts = [
      {
        # Auto-reconnect VPN when network connectivity is restored
        source = pkgs.writeText "vpn-auto-reconnect" ''
          #!/bin/sh
          INTERFACE=$1
          STATUS=$2
          VPN_NAME="BerekeBank"

          # Log function
          log() {
            logger -t "nm-vpn-reconnect" "$1"
          }

          # Only act on connectivity changes for non-VPN interfaces
          case "$INTERFACE" in
            tun*|vpn*)
              exit 0
              ;;
          esac

          case "$STATUS" in
            up|connectivity-change)
              # Wait a bit for network to stabilize
              sleep 3

              # Check if VPN is already connected
              VPN_STATE=$(nmcli -t -f GENERAL.STATE con show "$VPN_NAME" 2>/dev/null | grep -i activated)

              if [ -z "$VPN_STATE" ]; then
                log "Network connectivity restored, attempting VPN reconnection..."
                # Attempt to activate VPN (requires saved credentials or user interaction)
                # This will prompt for credentials via nm-applet if not saved
                nmcli con up "$VPN_NAME" 2>&1 | while read line; do log "$line"; done || true
              fi
              ;;
          esac
        '';
        type = "basic";
      }
    ];
  };

  # Install OpenConnect tools
  environment.systemPackages = with pkgs; [
    openconnect
    networkmanager-openconnect
  ];

  # Improve kernel network parameters for VPN stability
  boot.kernel.sysctl = {
    # Reduce TCP keepalive time for faster dead connection detection
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;

    # Improve UDP performance for DTLS
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # Reduce connection timeout for faster failover
    "net.ipv4.tcp_syn_retries" = 3;
    "net.ipv4.tcp_synack_retries" = 3;
  };

  # SystemD service to generate NetworkManager VPN connection with secrets
  systemd.services.networkmanager-berekebank-vpn = {
    description = "Generate NetworkManager BerekeBank VPN Connection";
    before = [ "NetworkManager.service" ];
    wantedBy = [ "NetworkManager.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "generate-berekebank-vpn" ''
        mkdir -p /etc/NetworkManager/system-connections

        # Read secrets
        GATEWAY=$(cat ${config.age.secrets.vpn-bereke-gateway.path})
        DNS=$(cat ${config.age.secrets.vpn-bereke-dns.path})
        DNS_SEARCH=$(cat ${config.age.secrets.vpn-bereke-dns-search.path})

        # Generate connection file with secrets
        cat > /etc/NetworkManager/system-connections/BerekeBank.nmconnection <<EOF
        [connection]
        id=BerekeBank
        type=vpn
        autoconnect=true

        [vpn]
        service-type=org.freedesktop.NetworkManager.openconnect
        gateway=$GATEWAY
        protocol=anyconnect
        useragent=AnyConnect

        [ipv4]
        method=auto
        dns=$DNS
        dns-search=$DNS_SEARCH
        ignore-auto-dns=true
        EOF

        chmod 0600 /etc/NetworkManager/system-connections/BerekeBank.nmconnection
        chown root:root /etc/NetworkManager/system-connections/BerekeBank.nmconnection
      '';
      ExecStop = "${pkgs.coreutils}/bin/rm -f /etc/NetworkManager/system-connections/BerekeBank.nmconnection";
    };
  };

  # Configure agenix secrets for VPN
  age.secrets.vpn-dahua-password = {
    file = ../../../secrets/vpn-dahua-password.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-dahua-host = {
    file = ../../../secrets/vpn-dahua-host.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-dahua-cert = {
    file = ../../../secrets/vpn-dahua-cert.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-bereke-gateway = {
    file = ../../../secrets/vpn-bereke-gateway.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-bereke-dns = {
    file = ../../../secrets/vpn-bereke-dns.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-bereke-dns-search = {
    file = ../../../secrets/vpn-bereke-dns-search.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  # OpenFortiVPN Configuration template for Dahua Dima (without secrets)
  environment.etc."openfortivpn/dahua-dima.conf.template" = {
    text = ''
      port = 10443
      username = cse
    '';
    mode = "0644";
  };

  # OpenFortiVPN systemd service
  systemd.services.openfortivpn-dahua = {
    description = "OpenFortiVPN - Dahua Dima";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ ];

    serviceConfig = {
      Type = "simple";
      # Generate config file with secrets before starting
      ExecStartPre = pkgs.writeShellScript "openfortivpn-prepare-config" ''
        mkdir -p /run/openfortivpn
        cp /etc/openfortivpn/dahua-dima.conf.template /run/openfortivpn/dahua-dima.conf
        echo "host = $(cat ${config.age.secrets.vpn-dahua-host.path})" >> /run/openfortivpn/dahua-dima.conf
        echo "password = $(cat ${config.age.secrets.vpn-dahua-password.path})" >> /run/openfortivpn/dahua-dima.conf
        echo "trusted-cert = $(cat ${config.age.secrets.vpn-dahua-cert.path})" >> /run/openfortivpn/dahua-dima.conf
        chmod 0600 /run/openfortivpn/dahua-dima.conf
      '';
      ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c /run/openfortivpn/dahua-dima.conf";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -f /run/openfortivpn/dahua-dima.conf";
      Restart = "on-failure";
      RestartSec = "10s";
      RuntimeDirectory = "openfortivpn";
      RuntimeDirectoryMode = "0700";
    };
  };
}
