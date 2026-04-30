{
  dotfiles,
  lib,
  pkgs,
  config,
  ...
}:
let
  dotfilesPath = dotfiles.paths.dotfiles;
in
lib.mkIf dotfiles.features.development.enable {
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;

    extensions = [
      # Languages
      "astro"
      "nix"
      "toml"
      "dockerfile"
      "docker-compose"
      "make"
      "csv"
      "log"
      "env"
      "graphql"
      "html"
      "proto"
      "sql"
      "svelte"
      "terraform"
      "vue"
      "xml"

      # Theme
      "catppuccin"
      "catppuccin-icons"

      # Tools
      "biome"
      "color-highlight"
      "editorconfig"
      "emmet"
      "github-actions"
      "git-firefly"
      "golangci-lint"
      "just"
      "markdown-oxide"

      # Snippets
      "go-snippets"
      "html-snippets"
      "javascript-snippets"
    ];
  };

  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zed/settings.json";

  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zed/keymap.json";
}
