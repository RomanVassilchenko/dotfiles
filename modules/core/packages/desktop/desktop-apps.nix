{ pkgs, ... }:
{
  # Core desktop utilities - only loaded on desktop/laptop (not server)
  # GUI apps with toggles are defined in modules/home/apps/*.nix
  environment.systemPackages = with pkgs; [
    appimage-run
    droidcam
    xdg-utils
  ];
}
