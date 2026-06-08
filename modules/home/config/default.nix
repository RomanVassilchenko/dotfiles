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
    ./helium.nix
    ./ssh.nix
    ./xdg.nix
  ]
  ++ lib.optionals dotfiles.features.stylix.enable [
    ./stylix.nix
  ];
}
