{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma = {
    workspace = {
      wallpaperSlideShow = {
        path = "${dotfiles.paths.dotfiles}/wallpapers";
        interval = 600;
      };
    };

    configFile = {
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Wallpaper/org.kde.slideshow/General".SlideshowMode =
        "Random";
    };
  };
}
