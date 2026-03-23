{
  pkgs,
  pkgs-stable,
  lib,
  vars,
  ...
}:
let
  workEnable = vars.workEnable or false;
in
{
  environment.systemPackages = [
    pkgs-stable.bruno
    pkgs-stable.dbeaver-bin
    pkgs-stable.freerdp
    pkgs.nixd # keep on unstable — tracks nixpkgs
    pkgs-stable.postman
  ]
  ++ lib.optionals workEnable [ pkgs-stable.camunda-modeler ];
}
