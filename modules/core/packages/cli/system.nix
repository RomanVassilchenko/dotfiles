{
  pkgs,
  pkgs-stable,
  lib,
  isServer,
  ...
}:
let
  dotCli = pkgs.writeShellScriptBin "dot" ''
    exec /home/romanv/Documents/dotfiles/dot.sh "$@"
  '';
in
{
  environment.systemPackages = [
    dotCli
    pkgs-stable.inxi
    pkgs-stable.lm_sensors
    pkgs-stable.pciutils
    pkgs-stable.sbctl
    pkgs-stable.trash-cli
    pkgs-stable.usbutils
  ]
  ++ lib.optionals (!isServer) [
    pkgs.v4l-utils
    pkgs.mesa-demos
  ];
}
