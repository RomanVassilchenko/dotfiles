{
  config,
  pkgs,
  pkgs-stable,
  lib,
  ...
}:
let
  desktopEnable = config.dotfiles.features.desktop.enable;
in
{

  services.earlyoom = {
    enable = true;
    enableNotifications = lib.mkDefault desktopEnable;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    freeMemKillThreshold = 2;
    freeSwapKillThreshold = 5;
    extraArgs = [
      "--avoid"
      "^(systemd|sshd|agetty|dbus)$"
      "--prefer"
      "^(Web Content|Isolated Web|firefox|chromium|brave|electron)$"
    ];
  };

  systemd.oomd.enable = false;

  services.irqbalance.enable = true;

  services.systembus-notify.enable = lib.mkForce desktopEnable;
}
