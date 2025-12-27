# Node.js and related tools - desktop only
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    playwright-driver.browsers
  ];
}
