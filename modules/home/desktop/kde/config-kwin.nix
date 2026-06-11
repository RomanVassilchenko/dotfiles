{
  dotfiles,
  lib,
  ...
}:
let
  kwinrc = import ./kwin/kwinrc.nix;
  kwinrules = import ./kwin/kwinrules.nix;
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma.configFile = {
    kwinrc = kwinrc.kwinrc;
    kwinrulesrc = kwinrules.kwinrulesrc;
  };
}
