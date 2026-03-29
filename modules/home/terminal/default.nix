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
    ./konsole.nix
    ./yakuake.nix
  ];
}
