{
  config,
  lib,
  ...
}:
let
  plasmaEnable = config.dotfiles.features.desktop.plasma.enable;
in
{
  networking.firewall = {
    enable = true;

    logReversePathDrops = true;
    logRefusedConnections = false;

    allowPing = true;

    allowedTCPPorts = [
      22
    ];

    allowedUDPPorts = [ ];

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

    extraCommands = "";
  };
}
