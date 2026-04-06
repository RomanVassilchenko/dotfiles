{
  config,
  pkgs,
  host,
  lib,
  options,
  ...
}:
let
  desktopEnable = config.dotfiles.features.desktop.enable;
  plasmaEnable = config.dotfiles.features.desktop.plasma.enable;
in
{
  systemd.services.NetworkManager.unitConfig = {
    StopWhenUnneeded = false;
    IgnoreOnIsolate = true;
  };

  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    modemmanager.enable = false;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
        8080
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
      allowedTCPPortRanges = lib.mkIf plasmaEnable [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = lib.mkIf plasmaEnable [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };

  environment.systemPackages = lib.optionals desktopEnable [ pkgs.networkmanagerapplet ];
}
