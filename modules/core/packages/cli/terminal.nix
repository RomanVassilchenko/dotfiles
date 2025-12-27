# Terminal support - available on all systems
{ pkgs, ... }:
{
  # Terminal info for SSH connections from Ghostty and other modern terminals
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];
}
