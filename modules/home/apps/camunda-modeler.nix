{
  lib,
  config,
  dotfiles,
  ...
}:
let
  dotfilesPath = dotfiles.paths.dotfiles;
in
lib.mkIf (dotfiles.features.work.enable && dotfiles.features.desktop.enable) {
  xdg.configFile."camunda-modeler/resources/plugins/camunda-modeler-dark-theme-plugin".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/camunda-modeler/plugins/camunda-modeler-dark-theme-plugin";
}
