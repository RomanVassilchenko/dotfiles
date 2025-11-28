{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    prismlauncher
    osu-lazer
  ];
}
