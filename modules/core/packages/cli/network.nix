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
      bind # provides nslookup, dig, host
      curl
      lsof
      openssh
      openssl
    ])
    ++ (with pkgs; [
      cloudflared
      wrangler
    ])
    ++ lib.optionals config.dotfiles.features.work.enable (
      with pkgs-stable;
      [
        vault
      ]
    )
    ++ lib.optionals config.dotfiles.features.work.enable [ pkgs-stable.openfortivpn ];
}
