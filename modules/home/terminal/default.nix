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
    ./wezterm.nix
  ];
}
