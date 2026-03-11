{
  lib,
  isServer,
  ...
}:
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

    allowedTCPPortRanges = lib.mkIf (!isServer) [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = lib.mkIf (!isServer) [
      {
        from = 1714;
        to = 1764;
      }
    ];

    extraCommands = "";
  };
}
