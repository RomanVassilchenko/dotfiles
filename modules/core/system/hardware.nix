{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostIsServer = config.dotfiles.host.isServer;
in
{
  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
    sane = lib.mkIf (!hostIsServer) {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ];
    };
    bluetooth = lib.mkIf (!hostIsServer) {
      enable = true;
      powerOnBoot = true;
    };
    keyboard.qmk.enable = !hostIsServer;
    logitech.wireless.enable = !hostIsServer;
    logitech.wireless.enableGraphical = !hostIsServer;
  };
}
