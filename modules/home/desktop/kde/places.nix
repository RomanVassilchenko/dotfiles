{
  config,
  dotfiles,
  lib,
  ...
}:
let
  home = config.home.homeDirectory;
  placesTemplate = builtins.readFile ./user-places.xbel;
  placesConfig = builtins.replaceStrings [ "@HOME@" ] [ home ] placesTemplate;
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  xdg.dataFile."user-places.xbel".text = placesConfig;
}
