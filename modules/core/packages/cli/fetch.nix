{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    onefetch
  ];
}
