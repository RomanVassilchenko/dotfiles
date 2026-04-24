{
  dotfiles,
  lib,
  ...
}:
let
  horizontalWallpaper = "file://${dotfiles.paths.dotfiles}/wallpapers/cannondale_horizontal.png";
  verticalWallpaper = "file://${dotfiles.paths.dotfiles}/wallpapers/cannondale_vertical.png";
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma.configFile = {
    "plasma-org.kde.plasma.desktop-appletsrc" = {
      "Containments/1".wallpaperplugin = "org.kde.image";
      "Containments/1/Wallpaper/org.kde.image/General".Image = horizontalWallpaper;

      "Containments/81".wallpaperplugin = "org.kde.image";
      "Containments/81/Wallpaper/org.kde.image/General".Image = verticalWallpaper;

      "Containments/82".wallpaperplugin = "org.kde.image";
      "Containments/82/Wallpaper/org.kde.image/General".Image = horizontalWallpaper;
    };
  };
}
