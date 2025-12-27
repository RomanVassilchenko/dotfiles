# Development packages - desktop only
# Server doesn't need development tools
{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./core.nix
    ./node.nix
    ./java.nix
    ./golang.nix
    ./protobuf.nix
    ./databases.nix
    ./tex.nix
    ./ai.nix
  ];
}
