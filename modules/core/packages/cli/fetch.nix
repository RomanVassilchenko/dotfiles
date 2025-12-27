# System/repo info fetchers - available on all systems
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Git repository info
    onefetch

    # System info (CLI version, no kitty graphics)
    fastfetch
  ];
}
