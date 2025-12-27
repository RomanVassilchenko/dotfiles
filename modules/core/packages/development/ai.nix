# AI CLI tools - desktop only
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    claude-code
    codex
    copilot-cli
  ];
}
