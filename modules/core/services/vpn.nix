{
  pkgs,
  lib,
  config,
  username,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  workEnable = vars.workEnable or false;
in
lib.mkIf workEnable {
  # Allow user to control VPN service without sudo password
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start openconnect-berekebank";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop openconnect-berekebank";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart openconnect-berekebank";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl status openconnect-berekebank";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Install OpenConnect tools
  environment.systemPackages = with pkgs; [
    openconnect
    oath-toolkit # For TOTP generation
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

  age.secrets.vpn-bereke-username = {
    file = ../../../secrets/vpn-bereke-username.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-bereke-password = {
    file = ../../../secrets/vpn-bereke-password.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets.vpn-bereke-totp-secret = {
    file = ../../../secrets/vpn-bereke-totp-secret.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  # OpenConnect VPN service for BerekeBank with automatic TOTP
  systemd.services.openconnect-berekebank = {
    description = "OpenConnect VPN - BerekeBank";
    after = [
      "network-online.target"
      "agenix.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.openconnect
      pkgs.oath-toolkit
      pkgs.coreutils
    ];

    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "openconnect-berekebank" ''
        # Read credentials from secrets
        USERNAME=$(cat ${config.age.secrets.vpn-bereke-username.path})
        PASSWORD=$(cat ${config.age.secrets.vpn-bereke-password.path})
        TOTP_SECRET=$(cat ${config.age.secrets.vpn-bereke-totp-secret.path})
        GATEWAY=$(cat ${config.age.secrets.vpn-bereke-gateway.path})

        # Generate TOTP code
        TOTP=$(oathtool --totp -b "$TOTP_SECRET")

        # Connect to VPN in foreground (no --background flag)
        # Password and TOTP are sent on separate lines
        echo -e "$PASSWORD\n$TOTP" | exec openconnect \
          --protocol=anyconnect \
          --user="$USERNAME" \
          --passwd-on-stdin \
          "$GATEWAY"
      '';
      Restart = "on-failure";
      RestartSec = "30s";
      # Wait for network to be fully up before starting
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
    };
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
