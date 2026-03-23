{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    fastfetch
    onefetch
  ];
}
