# Desktop apps - flatpak, fonts, steam
{ ... }:
{
  imports = [
    ./flatpak.nix
    ./fonts.nix
    ./steam.nix
  ];
}
