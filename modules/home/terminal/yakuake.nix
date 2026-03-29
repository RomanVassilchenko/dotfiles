{ pkgs, ... }:
{
  home.packages = [ pkgs.kdePackages.yakuake ];

  # Yakuake must be running to respond to the F12 toggle shortcut
  xdg.configFile."autostart/org.kde.yakuake.desktop".text = ''
    [Desktop Entry]
    Exec=yakuake
    Icon=yakuake
    Name=Yakuake
    Type=Application
    X-KDE-AutostartEnabled=true
    X-KDE-StartupNotify=false
  '';

  programs.plasma.configFile.yakuakerc = {
    Animation.Frames = 15;
    "Desktop Entry".DefaultProfile = "default.profile";
    Window = {
      Height = 40;
      Width = 100;
      ShowTabBar = false;
      ShowTitleBar = false;
    };
  };
}
