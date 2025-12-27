# CLI packages - available on all systems
{ ... }:
{
  imports = [
    ./core.nix
    ./system.nix
    ./network.nix
    ./media.nix
    ./fetch.nix
    ./terminal.nix
  ];
}
