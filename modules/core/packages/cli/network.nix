{
  config,
  pkgs,
  pkgs-stable,
  lib,
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
    ++ (with pkgs; [
      cloudflared # keep on unstable — actively updated
      wrangler
    ])
    ++ lib.optionals config.dotfiles.features.work.enable (
      with pkgs-stable;
      [
        kubectl
        kubernetes-helm
        vault
      ]
    )
    ++ lib.optionals config.dotfiles.features.work.enable [ pkgs-stable.openfortivpn ];
}
