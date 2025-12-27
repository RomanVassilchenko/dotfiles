# Essential CLI tools - available on all systems
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Version control
    git
    delta

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

    # Formatters (needed for dotfiles on server too)
    nixfmt-rfc-style
    shfmt
  ];
}
