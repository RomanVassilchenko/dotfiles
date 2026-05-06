{
  config,
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.stylix.enable (
  lib.mkMerge [
    (lib.mkIf (!dotfiles.features.desktop.plasma.enable) {
      gtk.gtk4.theme = config.gtk.theme;
    })

    {
      stylix.targets = {
        vscode.enable = false;
        zed.enable = false;
        qt.enable = false;
      };
    }
  ]
)
