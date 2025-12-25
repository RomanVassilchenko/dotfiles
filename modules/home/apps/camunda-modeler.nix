{
  pkgs,
  lib,
  config,
  vars,
  isServer,
  ...
}:
let
  workEnable = vars.workEnable or false;
  dotfilesPath = "/home/romanv/Documents/dotfiles";
in
lib.mkIf (workEnable && !isServer) {
  home.packages = [ pkgs.camunda-modeler ];

  xdg.configFile."camunda-modeler/resources/plugins/camunda-modeler-dark-theme-plugin".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/configs/camunda-modeler/plugins/camunda-modeler-dark-theme-plugin";
}
