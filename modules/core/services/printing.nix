{ pkgs-stable, vars, ... }:
let
  inherit (vars) printEnable;
in
{
  services = {
    printing = {
      enable = printEnable;
      drivers = [
        pkgs-stable.hplipWithPlugin
      ];
    };
    avahi = {
      enable = printEnable;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = printEnable;
  };
}
