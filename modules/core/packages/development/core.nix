{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = [
    pkgs-stable.act
    pkgs-stable.android-tools
    pkgs.glab # keep on unstable — actively developed
  ];
}
