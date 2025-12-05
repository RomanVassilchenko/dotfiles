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
lib.mkIf (!isServer) {
  # KDE Connect - Connect your phone to your desktop
  # Features: File sharing, clipboard sync, notifications, remote control, and more
  programs.kdeconnect.enable = true;

  # Firewall rules are handled in firewall.nix (ports 1714-1764 TCP/UDP)
}
