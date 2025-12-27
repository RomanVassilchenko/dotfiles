# Media processing CLI tools - available on all systems
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ffmpeg
    imagemagick
  ];
}
