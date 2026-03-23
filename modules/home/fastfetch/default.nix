{ lib, isServer, ... }:
lib.mkIf (!isServer) {
  programs.fastfetch.enable = true;
}
