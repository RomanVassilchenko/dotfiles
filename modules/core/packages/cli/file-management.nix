{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gzip
    unzip
    unrar
    zip
    stow
  ];
}
