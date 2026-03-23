{
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./files.nix
    ./git-hooks.nix
    ./git.nix
    ./ssh.nix
    ./xdg.nix
  ]
  ++ lib.optionals (!isServer) [
    ./stylix.nix
  ];
}
