{
  lib,
  vars,
  ...
}:
let
  deviceType = vars.deviceType or "laptop";
in
{
  imports = lib.optionals (deviceType != "server") [
    ./apps.nix
    ./browsers.nix
    ./communication.nix
    ./creative.nix
    ./devtools.nix
    ./gaming.nix
    ./hardware.nix
    ./productivity.nix
  ];
}
