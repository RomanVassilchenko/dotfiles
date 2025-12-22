{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Full TeX Live distribution (includes all standard packages)
    texlive.combined.scheme-full

    # Fonts
    inter
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    source-code-pro
    fira-code

    # PDF tools
    ghostscript
  ];
}
