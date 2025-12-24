{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cmatrix
    cowsay
    lolcat
    onefetch
  ];
}
