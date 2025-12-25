{ pkgs, ... }:
{
  # CLI media tools (system-wide)
  # GUI apps (gimp, krita, inkscape) are in modules/home/apps/*.nix
  environment.systemPackages = with pkgs; [
    ffmpeg
    imagemagick
  ];
}
