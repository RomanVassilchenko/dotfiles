{ pkgs, ... }:
{
  home.packages = with pkgs; [
    codex
    nodejs
  ];
}
