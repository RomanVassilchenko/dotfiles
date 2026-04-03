{
  config,
  lib,
  pkgs-stable,
  ...
}:
{
  environment.systemPackages = lib.optionals config.dotfiles.features.apps.solaar.enable [
    pkgs-stable.solaar
  ];
}
