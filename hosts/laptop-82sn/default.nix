{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  features.communication.enable = true;
  features.desktop.enable = true;
  features.development.enable = true;
  features.hardware.enable = true;
  features.kde.enable = true;
  features.printing.enable = true;
  features.productivity.enable = true;
  features.stylix.enable = true;
  features.work.enable = true;

  features.apps.bitwarden.autostart = true;
  features.apps.telegram.autostart = true;
  features.apps.zapzap.autostart = true;
}
