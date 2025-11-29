{ pkgs, ... }:
{
  hardware.steam-hardware.enable = true; # Steam controller and hardware support

  environment.systemPackages = with pkgs; [
    prismlauncher
    osu-lazer
  ];
}
