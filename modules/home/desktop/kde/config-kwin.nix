{
  dotfiles,
  lib,
  ...
}:
let
  kwinrc = import ./kwin/_kwinrc.nix;
  kwinrules = import ./kwin/_kwinrules.nix;
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma.configFile = {
    kwinrc = kwinrc.kwinrc;
    kwinrulesrc = kwinrules.kwinrulesrc;
  };
}
