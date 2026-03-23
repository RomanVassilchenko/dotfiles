{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./fonts.nix
    ./niri.nix
    ./plasma.nix
    ./stylix.nix
  ];
}
