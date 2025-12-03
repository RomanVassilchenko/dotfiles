{
  profile,
  lib,
  host,
  ...
}:
let
  vars = import ../../hosts/${host}/variables.nix;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";
in
{
  # Services to start
  services = {
    # Server-compatible services (always enabled)
    fstrim.enable = true; # SSD Optimizer
    openssh = {
      enable = true; # Enable SSH
      settings = {
        PermitRootLogin = "no"; # Prevent root from SSH login
        PasswordAuthentication = true; # Users can SSH using kb and password
        KbdInteractiveAuthentication = true;

        # Post-quantum key exchange algorithms for SSH server
        # Protects against "store now, decrypt later" attacks
        # Hybrid algorithms combine post-quantum + classical crypto for security and compatibility
        KexAlgorithms = [
          "mlkem768x25519-sha256" # NIST ML-KEM-768 + X25519 (recommended, FIPS-approved)
          "sntrup761x25519-sha512@openssh.com" # Streamlined NTRU Prime + X25519
          "curve25519-sha256" # Classical fallback
          "curve25519-sha256@libssh.org" # Classical fallback (alternate)
          "diffie-hellman-group-exchange-sha256" # Classical fallback (legacy)
        ];
      };
      ports = [ 22 ];
    };

    smartd = {
      enable = if profile == "vm" then false else true;
      autodetect = true;
    };

    # Desktop/laptop-specific services
    libinput.enable = !isServer; # Input Handling (GUI only)
    gvfs.enable = !isServer; # For Mounting USB & More (GUI only)
    power-profiles-daemon.enable = !isServer; # Power profile management (laptop only)

    logind.settings.Login = lib.mkIf (!isServer) {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    pipewire = lib.mkIf (!isServer) {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 256;
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "256/48000";
              pulse.default.req = "256/48000";
              pulse.max.req = "256/48000";
              pulse.min.quantum = "256/48000";
              pulse.max.quantum = "256/48000";
            };
          }
        ];
      };
    };
  };
}
