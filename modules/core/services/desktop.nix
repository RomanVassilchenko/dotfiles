{ lib, isServer, ... }:
{
  # After 30 min of sleep → auto-hibernate (0W power draw)
  systemd.sleep.settings.Sleep = lib.mkIf (!isServer) {
    HibernateDelaySec = "30min";
  };
  services = {
    libinput.enable = true;

    gvfs.enable = true;

    logind.settings.Login = {
      # Off AC: suspend first, hibernate after HibernateDelaySec
      HandleLidSwitch = "suspend-then-hibernate";
      # On AC: just suspend, no need to hibernate
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    # Hibernate on critical battery
    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "512/48000";
              pulse.default.req = "1024/48000";
              pulse.max.req = "2048/48000";
              pulse.min.quantum = "512/48000";
              pulse.max.quantum = "2048/48000";
            };
          }
        ];
      };
    };
  };
}
