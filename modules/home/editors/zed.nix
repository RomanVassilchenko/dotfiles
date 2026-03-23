{ pkgs, config, ... }:
let
  dotfilesPath = "/home/romanv/Documents/dotfiles";
in
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;

    extensions = [
      # Languages
      "nix"
      "toml"
      "dockerfile"
      "make"
      "csv"
      "log"

      # Theme
      "catppuccin"
      "catppuccin-icons"

      # Tools
      "git-firefly"
    ];
  };

  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zed/settings.json";

  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zed/keymap.json";
}
