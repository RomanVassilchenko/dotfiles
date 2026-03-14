{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    google-chrome
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
