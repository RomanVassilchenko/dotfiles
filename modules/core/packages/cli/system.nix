# System monitoring and hardware info tools - available on all systems
{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      # System monitoring
      inxi
      lshw
      lm_sensors
      pciutils
      usbutils

      # Disk usage
      ncdu
      duf
      dysk
    ]
    ++ lib.optionals (!isServer) [
      # GPU/video tools - desktop only
      v4l-utils
      mesa-demos
    ];
}
