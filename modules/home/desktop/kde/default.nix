{
  config,
  inputs,
  lib,
  nhModules,
  pkgs,
  ...
}:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./autostart.nix
    ./config.nix
    ./panels.nix
    ./wallpaper.nix
    ./widgets.nix
  ];

  home.packages = with pkgs; [
    kde-rounded-corners
    kdePackages.kcalc
    kdePackages.krohnkite
    kdotool
    libnotify
    inputs.plasma-manager.packages.${pkgs.stdenv.hostPlatform.system}.rc2nix
  ];

  programs.plasma = {
    # Appearance settings
    workspace.colorScheme = "BreezeDark";
  };
}
