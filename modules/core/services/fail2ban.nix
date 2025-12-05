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
  # Fail2ban - Intrusion prevention (ban IPs after failed login attempts)
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "168h"; # Max 1 week ban
      factor = "4";
    };
    ignoreIP = [
      "127.0.0.1/8"
      "192.168.0.0/16"
      "10.0.0.0/8"
      "172.16.0.0/12"
    ];
    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          maxretry = 5;
          findtime = "10m";
          bantime = "1h";
        };
      };
    };
  };
}
