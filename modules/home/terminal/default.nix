{
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./tmux.nix
  ]
  ++ lib.optionals (!isServer) [
    ./ghostty.nix
  ];
}
