{
  programs.plasma = {
    workspace = {
      # Global wallpaper configuration
      # This sets the default wallpaper for all desktops/screens
      wallpaper = "/home/romanv/Documents/dotfiles/wallpapers/kurzgesagt-galaxies.jpg";
    };

    # TODO: Per-desktop or per-screen wallpaper configuration
    # plasma-manager may support this through workspace.wallpaperPictureOfTheDay or similar options
    # For now, configure different wallpapers per desktop through KDE System Settings GUI:
    # Right-click desktop → Configure Desktop and Wallpaper → select different wallpaper per desktop
    #
    # Available wallpapers in /home/romanv/Documents/dotfiles/wallpapers/:
    # - AnimeGirlNightSky.jpg
    # - Rainnight.jpg
    # - mountainscapedark.jpg
    # - cyberpunk.png
    # - dark-forest.jpg
    # - escape_velocity.jpg
    # - puffy-stars.jpg
    # - train.jpg
    # - train-sideview.jpg
    # - evening-sky.jpg
    # - kurzgesagt.jpg
    # - kurzgesagt-galaxies.jpg
    # - moon.jpg
  };
}
