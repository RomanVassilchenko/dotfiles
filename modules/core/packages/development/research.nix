{
  config,
  lib,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = with pkgs-stable; [
    # texlive.combined.scheme-full # ~5GB, enable when needed
    fira-code
    ghostscript
    liberation_ttf
    source-code-pro
    tinymist
    typst
  ];
}
