{
  dotfiles,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = lib.optionals dotfiles.features.desktop.plasma.enable [
    inputs.plasma-manager.packages.${pkgs.stdenv.hostPlatform.system}.rc2nix
  ];
}
