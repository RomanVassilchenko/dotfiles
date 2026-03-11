{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    act
    android-tools
    glab
  ];
}
