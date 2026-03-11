{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # lazysql # Database TUI
    postgresql
    squawk
  ];
}
