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
  ];
}
