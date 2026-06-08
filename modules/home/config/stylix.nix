{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.stylix.enable (
  lib.mkMerge [
    {
      stylix.targets = {
        vscode.enable = false;
        zed.enable = false;
        qt.enable = false;
      };
    }
  ]
)
