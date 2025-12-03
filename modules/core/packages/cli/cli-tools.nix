{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    eza
    jq
    tree
    bc
    killall
    libnotify
    cmatrix
    cowsay
    lolcat
    onefetch
    pandoc
    xdg-ninja

    # CLI tools useful on both desktop and server
    bitwarden-cli
    claude-code
    codex
    distrobox
    docker-compose
  ];
}
