{
  config,
  lib,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  fonts = {
    packages = with pkgs-stable; [
      font-awesome
      material-symbols
      noto-fonts
      noto-fonts-cjk-sans
      roboto-mono
      # icon fonts
      nerd-fonts.symbols-only
    ];
  };
}
