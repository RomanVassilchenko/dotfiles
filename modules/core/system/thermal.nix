{
  lib,
  pkgs,
  isServer,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  services.power-profiles-daemon.enable = lib.mkForce false;

  services.tlp = {
    enable = true;
    settings =
      if isServer then
        {
          CPU_SCALING_GOVERNOR_ON_AC = "powersave";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_BOOST_ON_AC = 0;
          CPU_BOOST_ON_BAT = 0;

          CPU_MAX_PERF_ON_AC = 70;
          CPU_MAX_PERF_ON_BAT = 70;
          CPU_MIN_PERF_ON_AC = 0;
          CPU_MIN_PERF_ON_BAT = 0;

          CPU_ENERGY_PERF_POLICY_ON_AC = "power";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        }
      else
        {
          CPU_SCALING_GOVERNOR_ON_AC = "powersave";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          CPU_MAX_PERF_ON_AC = 100;
          CPU_MAX_PERF_ON_BAT = 60;
          CPU_MIN_PERF_ON_AC = 0;
          CPU_MIN_PERF_ON_BAT = 0;

          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";
        };
  };
}
