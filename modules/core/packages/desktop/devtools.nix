{
  pkgs,
  lib,
  vars,
  ...
}:
let
  workEnable = vars.workEnable or false;
in
{
  environment.systemPackages = [
    pkgs.dbeaver-bin
    pkgs.freerdp
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.goland
    pkgs.nixd
    pkgs.postman
  ]
  ++ lib.optionals workEnable [ pkgs.camunda-modeler ];
}
