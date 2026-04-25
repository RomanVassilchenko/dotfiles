{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.dotfiles.locale) consoleKeyMap;
  desktopEnable = config.dotfiles.features.desktop.enable;
in
{
  nix = {
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings = {
      download-buffer-size = 200000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" # llm-agents.nix
      ];
      max-jobs = 12;
      cores = 0;
      keep-outputs = true;
      keep-derivations = true;
      http-connections = 128;
      max-substitution-jobs = 128;
      narinfo-cache-negative-ttl = 0;
      min-free = 1073741824;
      max-free = 5368709120;
      warn-dirty = false;
      fallback = true;
      connect-timeout = 5;
      use-xdg-base-directories = true;
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
  environment = {
    variables = {
      PLAYWRIGHT_BROWSERS_PATH = lib.mkIf config.dotfiles.features.development.enable "${pkgs.playwright-driver.browsers
      }";
    }
    // lib.optionalAttrs desktopEnable {
      NIXOS_OZONE_WL = "1";
    };

    localBinInPath = true;
    extraInit = ''
      export PATH="/usr/local/bin:$PATH"
    '';
  };
  console.keyMap = consoleKeyMap;
  system.stateVersion = "23.11";

  documentation = lib.mkIf config.dotfiles.host.isServer {
    enable = false;
    man.enable = false;
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
}
