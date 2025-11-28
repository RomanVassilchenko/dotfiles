{ host, ... }:
let
  inherit (import ../../../hosts/${host}/variables.nix) consoleKeyMap;
in
{
  nix = {
    settings = {
      download-buffer-size = 200000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # Build optimization
      max-jobs = 12;
      cores = 0; # Auto-detect and use all cores per build job
      keep-outputs = false;
      keep-derivations = false;
      # Parallel downloads
      http-connections = 128;
      # Warn on dirty git trees but don't fail
      warn-dirty = false;
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
  };
  console.keyMap = "${consoleKeyMap}";
  system.stateVersion = "23.11"; # Do not change!
}
