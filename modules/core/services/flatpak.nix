{ config, lib, ... }:
lib.mkIf config.dotfiles.features.desktop.enable {
  services.flatpak = {
    enable = true;

    packages = [ ];

    update.onActivation = false;
    update.auto.enable = false;
  };
}
