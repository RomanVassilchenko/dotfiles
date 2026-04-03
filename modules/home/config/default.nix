{
  dotfiles,
  lib,
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
  ++ lib.optionals dotfiles.features.stylix.enable [
    ./stylix.nix
  ];
}
