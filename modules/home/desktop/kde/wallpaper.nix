{
  programs.plasma = {
    workspace = {
      # Wallpaper slideshow from dotfiles wallpapers folder
      wallpaperSlideShow = {
        path = "/home/romanv/Documents/dotfiles/wallpapers";
        interval = 600; # 10 minutes
      };
    };

    # Configure slideshow to use random order
    configFile = {
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments/1/Wallpaper/org.kde.slideshow/General".SlideshowMode =
        "Random";
    };
  };
}
