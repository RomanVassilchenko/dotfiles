{
  config,
  lib,
  pkgs-stable,
  ...
}:
let
  printEnable = config.dotfiles.features.printing.enable;
in
lib.mkIf (config.dotfiles.features.desktop.enable && printEnable) {
  services = {
    printing = {
      enable = true;
      drivers = [
        pkgs-stable.hplipWithPlugin
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
  };
}
