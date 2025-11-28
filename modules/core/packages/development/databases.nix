{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dbeaver-bin
    postgresql
    squawk
  ];
}
