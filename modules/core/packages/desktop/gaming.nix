{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  hardware.steam-hardware.enable = true;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # heroic # GOG/Epic/Amazon games launcher
    # lutris # Gaming platform
    # osu-lazer # osu! rhythm game
    mangohud
    prismlauncher
  ];
}
