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
      # lazyssh # SSH manager TUI - verify usage
      bind # provides nslookup, dig, host
      cloudflared
      curl
      lsof
      openssh
      openssl
      xh # Modern httpie alternative (Rust)
    ]
    ++ lib.optionals (!isServer) [
      openfortivpn
    ];
}
