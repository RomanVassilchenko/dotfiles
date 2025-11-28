{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    wget
    openssh
    openssl
    openfortivpn
    cloudflared
    socat
    lsof
    bind # provides nslookup, dig, host
  ];
}
