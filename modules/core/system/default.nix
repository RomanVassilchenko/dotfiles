# System configuration - all systems
{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./network.nix
    ./security.nix
    ./system.nix
    ./user.nix
    ./virtualisation.nix
  ];
}
