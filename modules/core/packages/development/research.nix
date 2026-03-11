{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # texlive.combined.scheme-full
    fira-code
    ghostscript
    liberation_ttf
    source-code-pro
    tinymist
    typst
  ];
}
