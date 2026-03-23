{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.plasma.workspace.colorScheme = "CatppuccinMochaMauve";

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = lib.mkForce "catppuccin-mocha-mauve-standard";
      package = lib.mkForce (
        pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "mauve" ];
        }
      );
    };
    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      package = lib.mkForce (
        pkgs.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "mauve";
        }
      );
    };
  };

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde";
    style.name = lib.mkForce "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-mocha-mauve
  '';
}
