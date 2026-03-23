{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    postgresql
    squawk
  ];
}
