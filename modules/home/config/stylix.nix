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
      programs.firefox = {
        enable = true;
        package = null;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        profiles.default = {
          id = 0;
          path = "izitbjng.default";
          isDefault = true;
          extensions.force = true;
        };
      };

      stylix.targets = {
        firefox = {
          profileNames = [ "default" ];
          colorTheme.enable = true;
        };
        vscode.enable = false;
        zed.enable = false;
        qt.enable = false;
      };
    }
  ]
)
