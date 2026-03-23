{
  pkgs,
  pkgs-stable,
  lib,
  isServer,
  ...
}:
{

  services.ananicy = {
    enable = true;
    package = pkgs-stable.ananicy-cpp;
    rulesProvider = pkgs-stable.ananicy-rules-cachyos;
    settings = {
      check_freq = 5;
      cgroup_load = true;
      type_load = true;
      rule_load = true;
      apply_nice = true;
      apply_ioclass = true;
      apply_ionice = true;
      apply_sched = true;
      apply_oom_score_adj = true;
      apply_cgroup = true;
    };
  };

  services.earlyoom = {
    enable = true;
    enableNotifications = lib.mkDefault (!isServer);
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

  services.irqbalance.enable = true;

  services.systembus-notify.enable = lib.mkForce (!isServer);
}
