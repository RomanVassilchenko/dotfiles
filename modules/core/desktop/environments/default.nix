# Desktop environments - X11 and Plasma
{ ... }:
{
  imports = [
    ./xserver.nix
    ./plasma.nix
    ./plasma-xdg-fix.nix
  ];
}
