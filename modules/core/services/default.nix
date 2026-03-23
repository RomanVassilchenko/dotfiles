{
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./common.nix
    ./firewall.nix
    ./performance.nix
  ]
  ++ lib.optionals (!isServer) [
    ./desktop.nix
    ./flatpak.nix
    ./kdeconnect.nix
    ./logiops.nix
    ./printing.nix
    ./virtual-mic.nix
  ]
  ++ lib.optionals isServer [
    ./server
  ];
}
