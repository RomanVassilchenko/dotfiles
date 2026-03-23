{
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./ai.nix
  ]
  ++ lib.optionals (!isServer) [
    ./core.nix
    ./databases.nix
    ./golang.nix
    ./java.nix
    ./node.nix
    ./protobuf.nix
    ./research.nix
  ];
}
