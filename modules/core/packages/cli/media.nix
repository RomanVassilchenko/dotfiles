{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    ffmpeg
    imagemagick
    mpv
    poppler-utils
  ];
}
