{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  # Ananicy-cpp - Process priority management for better desktop responsiveness
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
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

  # Earlyoom - Out of memory killer (prevents system freeze on OOM)
  services.earlyoom = {
    enable = true;
    enableNotifications = lib.mkDefault (!isServer); # Desktop notifications only on GUI systems
    freeMemThreshold = 5; # Start killing when 5% free memory
    freeSwapThreshold = 10; # And 10% free swap
    freeMemKillThreshold = 2; # Kill when 2% free memory
    freeSwapKillThreshold = 5; # Kill when 5% free swap
    extraArgs = [
      "--avoid"
      "^(systemd|sshd|agetty|dbus)$" # Never kill critical services
      "--prefer"
      "^(Web Content|Isolated Web|firefox|chromium|brave|electron)$" # Prefer killing browsers
    ];
  };

  # Irqbalance - Distribute hardware interrupts across processors
  services.irqbalance.enable = true;

  # Resolve conflict between earlyoom and smartd for systembus-notify
  services.systembus-notify.enable = lib.mkForce (!isServer);

  # Thermald - Thermal management (Intel CPUs)
  # services.thermald.enable = true;  # Enable if using Intel CPU
}
