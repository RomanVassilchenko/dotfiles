{
  programs.plasma = {
    workspace = {
      wallpaperSlideShow = {
        path = "/home/romanv/Documents/dotfiles/wallpapers";
        interval = 600;
      };
    };

    configFile = {
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Wallpaper/org.kde.slideshow/General".SlideshowMode =
        "Random";
    };
  };
}
