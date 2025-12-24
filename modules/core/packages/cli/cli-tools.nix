{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core utilities
    ripgrep
    fd
    eza
    jq
    tree
    bc
    killall
    libnotify
    xdg-ninja

    # CLI tools useful on both desktop and server
    bitwarden-cli
    distrobox
    docker-compose
  ];
}
