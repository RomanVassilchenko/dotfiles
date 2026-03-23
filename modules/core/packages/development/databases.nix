{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    # lazysql # Database TUI
    postgresql
    squawk
  ];
}
