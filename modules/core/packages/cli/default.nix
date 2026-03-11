# CLI packages - available on all systems
{ ... }:
{
  imports = [
    ./containers.nix
    ./core.nix
    ./fetch.nix
    ./media.nix
    ./network.nix
    ./system.nix
    ./terminal.nix
  ];
}
