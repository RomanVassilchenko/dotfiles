{ dotfiles, lib, ... }:
lib.mkIf dotfiles.features.desktop.enable {
  programs.fastfetch.enable = true;
  home.shellAliases.ff = "fastfetch";
}
