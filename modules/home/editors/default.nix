{
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./micro.nix
  ]
  ++ lib.optionals (!isServer) [
    ./vscode.nix
    ./zed.nix
  ];
}
