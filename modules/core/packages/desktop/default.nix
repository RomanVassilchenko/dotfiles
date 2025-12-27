# Desktop packages - only loaded on desktop/laptop (not server)
{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./apps.nix
    ./gaming.nix
  ];
}
