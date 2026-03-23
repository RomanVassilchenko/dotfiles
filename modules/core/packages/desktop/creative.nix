{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    gimp
    inkscape-with-extensions
  ];
}
