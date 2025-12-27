# Desktop configuration - only loaded on desktop/laptop (not server)
{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./stylix.nix
    ./apps
    ./environments
    ./display-managers
  ];
}
