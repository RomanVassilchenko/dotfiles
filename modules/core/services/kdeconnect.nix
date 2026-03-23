{
  lib,
  isServer,
  ...
}:
lib.mkIf (!isServer) {
  programs.kdeconnect.enable = true;
}
