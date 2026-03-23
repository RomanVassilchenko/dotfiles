{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./fonts.nix
    ./plasma.nix
    ./stylix.nix
  ];
}
