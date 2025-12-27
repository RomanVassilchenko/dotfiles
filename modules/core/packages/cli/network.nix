# Network tools - available on all systems
{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      # Core networking
      curl
      wget
      openssh
      openssl
      socat
      lsof

      # DNS tools
      bind # provides nslookup, dig, host
    ]
    ++ lib.optionals (!isServer) [
      # VPN tools - desktop only (server has its own VPN config)
      openfortivpn
      cloudflared
    ];
}
