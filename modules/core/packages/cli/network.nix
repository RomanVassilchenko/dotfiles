{
  pkgs,
  pkgs-stable,
  lib,
  isServer,
  ...
}:
{
  environment.systemPackages =
    (with pkgs-stable; [
      # lazyssh # SSH manager TUI
      bind # provides nslookup, dig, host
      curl
      lsof
      openssh
      openssl
      xh # Modern httpie alternative (Rust)
    ])
    ++ [ pkgs.cloudflared ] # keep on unstable — actively updated
    ++ lib.optionals (!isServer) [ pkgs-stable.openfortivpn ];
}
