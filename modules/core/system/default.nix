{
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./local-hardware-clock.nix
    ./network.nix
    ./security.nix
    ./system.nix
    ./thermal.nix
    ./user.nix
    ./virtualisation.nix
  ]
  ++ lib.optionals (!isServer) [
    ./boot-desktop.nix
  ];
}
