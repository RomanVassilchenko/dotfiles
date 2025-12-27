# Essential CLI tools - available on all systems
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core utilities
    ripgrep
    fd
    jq
    tree
    bc
    killall

    # Archive tools
    gzip
    unzip
    unrar
    zip

    # Symlink management
    stow

    # XDG compliance checker
    xdg-ninja
  ];
}
