{
  dotfiles,
  lib,
  ...
}:
let
  shortcuts = import ./_shortcuts.nix;
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma = {
    enable = true;

    powerdevil = {
      AC = {
        autoSuspend = {
          action = "sleep";
          idleTimeout = 3600;
        };
        turnOffDisplay = {
          idleTimeout = 600;
          idleTimeoutWhenLocked = "immediately";
        };
      };
    };

    shortcuts = shortcuts;
  };
}
