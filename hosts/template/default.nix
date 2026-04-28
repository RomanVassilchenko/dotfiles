{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  features = {
    development.enable = true;
    kde.enable = true;
    productivity.enable = true;
    stylix.enable = true;
  };
}
