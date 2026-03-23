{ pkgs, ... }:
{
  hardware = {
    sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ];
    };
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    enableRedistributableFirmware = true;
    graphics.enable = true;
    keyboard.qmk.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true;
  };
}
