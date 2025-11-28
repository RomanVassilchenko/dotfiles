{ pkgs, config, ... }:
{
  # Enable OpenConnect support for AnyConnect VPN
  networking.networkmanager = {
    plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };

  # Install OpenConnect tools
  environment.systemPackages = with pkgs; [
    openconnect
    networkmanager-openconnect
  ];

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
