{ config, lib, ... }:
lib.mkIf config.dotfiles.features.desktop.enable {
  services.flatpak = {
    enable = true;

    packages = [ ];

    update.onActivation = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
