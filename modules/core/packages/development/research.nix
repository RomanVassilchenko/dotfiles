{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    fira-code
    ghostscript
    liberation_ttf
    source-code-pro
    tinymist
    typst
  ];
}
