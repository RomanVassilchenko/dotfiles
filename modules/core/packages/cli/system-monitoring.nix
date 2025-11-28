{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    htop
    inxi
    lshw
    lm_sensors
    pciutils
    usbutils
    v4l-utils
    mesa-demos
    ncdu
    duf
    dysk
  ];
}
