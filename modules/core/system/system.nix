{
  host,
  lib,
  pkgs,
  isServer,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) consoleKeyMap;
in
{
  nix = {
    # Automatic store optimization (weekly deduplication)
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Note: GC handled by nh.clean for all systems

    settings = {
      download-buffer-size = 200000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Substituters: ninkear cache via Tailscale P2P only (falls back to building if unavailable)
      substituters = [
        "https://nix-community.cachix.org"
      ]
      ++ lib.optionals (!isServer) [
        "http://100.64.0.1:5000" # ninkear via Tailscale P2P
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ]
      ++ lib.optionals (!isServer) [
        "ninkear-cache:sNCVuzpn+Ku3BRQZztAMz2fhDL4/0PkE7+IGYwIn+90="
      ];
      # Build optimization
      max-jobs = 12;
      cores = 0; # Auto-detect and use all cores per build job
      keep-outputs = false;
      keep-derivations = false;
      # Parallel downloads
      http-connections = 128;
      # Download all dependencies before building (substitution jobs > max-jobs)
      max-substitution-jobs = 128;
      # Warn on dirty git trees but don't fail
      warn-dirty = false;
      # Allow falling back to building if cache is unreachable
      fallback = true;
      # Don't fail if ninkear cache is unreachable
      connect-timeout = 5;
    };
  };
  time.timeZone = "Asia/Almaty";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };

  # Add /usr/local/bin to PATH for dot CLI and other local binaries
  environment.localBinInPath = true;
  environment.extraInit = ''
    export PATH="/usr/local/bin:$PATH"
  '';
  console.keyMap = "${consoleKeyMap}";
  system.stateVersion = "23.11"; # Do not change!

  # Disable documentation on server to save space and build time
  documentation = lib.mkIf isServer {
    enable = false;
    man.enable = false;
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };
}
