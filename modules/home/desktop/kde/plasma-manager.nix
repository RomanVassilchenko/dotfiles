{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = [
    inputs.plasma-manager.packages.${pkgs.stdenv.hostPlatform.system}.rc2nix
  ];
}
