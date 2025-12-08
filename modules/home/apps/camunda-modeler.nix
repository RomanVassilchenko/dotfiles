{
  lib,
  config,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  workEnable = vars.workEnable or false;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";

  dotfilesPath = "/home/romanv/dotfiles";
in
lib.mkIf (workEnable && !isServer) {
  xdg.configFile."camunda-modeler/resources/plugins/camunda-modeler-dark-theme-plugin".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/configs/camunda-modeler/plugins/camunda-modeler-dark-theme-plugin";
}
