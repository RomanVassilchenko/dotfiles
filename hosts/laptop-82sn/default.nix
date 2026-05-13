{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  features = {
    communication.enable = true;
    desktop.enable = true;
    development.enable = true;
    hardware.enable = true;
    kde.enable = true;
    productivity.enable = true;
    stylix.enable = true;
    work.enable = true;

    apps = {
      bitwarden.autostart = true;
      telegram.autostart = true;
      thunderbird.autostart = true;
      zapzap.autostart = true;
    };
  };
}
