{
  lib,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";
in
{
  networking.firewall = {
    enable = true;

    # Log dropped packets for debugging (optional, can be noisy)
    logReversePathDrops = true;
    logRefusedConnections = false; # Set to true for debugging

    # Allow ping
    allowPing = true;

    # TCP ports
    allowedTCPPorts = [
      22 # SSH
    ];

    # UDP ports
    allowedUDPPorts = [ ];

    # KDE Connect ports (laptop/desktop only)
    allowedTCPPortRanges = lib.mkIf (!isServer) [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = lib.mkIf (!isServer) [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];

    # Extra commands for more advanced rules (if needed)
    extraCommands = '''';
  };
}
