{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ffmpeg
    gimp
    krita
    inkscape-with-extensions
    imagemagick
  ];
}
