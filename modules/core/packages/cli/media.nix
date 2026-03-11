{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ffmpeg
    imagemagick
    mpv
    yt-dlp
  ];
}
