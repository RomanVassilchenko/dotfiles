{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  xdg.desktopEntries.plasma-notifications-window = {
    name = "Notification History";
    exec = "plasmawindowed org.kde.plasma.notifications";
    icon = "preferences-desktop-notification";
    terminal = false;
    categories = [
      "Utility"
      "System"
    ];
  };
}
