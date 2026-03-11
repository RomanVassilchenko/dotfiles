{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # droidcam
    appimage-run
    xdg-utils
  ];
}
