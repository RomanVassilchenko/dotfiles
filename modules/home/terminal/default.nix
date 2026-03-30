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
    ./kitty.nix
  ];
}
