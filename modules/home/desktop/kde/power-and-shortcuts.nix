{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma = {
    enable = true;

    powerdevil = {
      AC = {
        autoSuspend = {
          action = "sleep";
          idleTimeout = 3600;
        };
        turnOffDisplay = {
          idleTimeout = 600;
          idleTimeoutWhenLocked = "immediately";
        };
      };
    };

    shortcuts = {
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Ctrl+Space";

      kwin = {
        KrohnkiteFocusDown = "Meta+Down";
        KrohnkiteFocusLeft = "Meta+Left";
        KrohnkiteFocusRight = "Meta+Right";
        KrohnkiteFocusUp = "Meta+Up";
        KrohnkiteGrowHeight = "Meta+Ctrl+Down";
        KrohnkitegrowWidth = "Meta+Ctrl+Right";
        KrohnkiteIncrease = "Meta+I";
        KrohnkiteNextLayout = "Meta+Space";
        KrohnkitePreviousLayout = "Meta+Shift+Space";
        KrohnkiteSetMaster = "Meta+Shift+Return";
        KrohnkiteShiftDown = "Meta+Shift+Down";
        KrohnkiteShiftLeft = "Meta+Shift+Left";
        KrohnkiteShiftRight = "Meta+Shift+Right";
        KrohnkiteShiftUp = "Meta+Shift+Up";
        KrohnkiteShrinkHeight = "Meta+Ctrl+Up";
        KrohnkiteShrinkWidth = "Meta+Ctrl+Left";
        KrohnkiteToggleFloat = "Meta+F";

        "Move with Window to Desktop 1" = "Meta+Ctrl+1";
        "Move with Window to Desktop 2" = "Meta+Ctrl+2";
        "Move with Window to Desktop 3" = "Meta+Ctrl+3";
        "Move with Window to Desktop 4" = "Meta+Ctrl+4";
        "Switch to Desktop 1" = [
          "Meta+1"
          "Meta+Num+1"
        ];
        "Switch to Desktop 2" = [
          "Meta+2"
          "Meta+Num+2"
        ];
        "Switch to Desktop 3" = [
          "Meta+3"
          "Meta+Num+3"
        ];
        "Switch to Desktop 4" = [
          "Meta+4"
          "Meta+Num+4"
        ];
        "Switch to Next Desktop" = "Meta+PgDown";
        "Switch to Previous Desktop" = "Meta+PgUp";
        "Toggle Tiling" = [ ];
        "Window Quick Tile Bottom" = "Meta+Ctrl+Alt+Down";
        "Window Quick Tile Left" = "Meta+Ctrl+Alt+Left";
        "Window Quick Tile Right" = "Meta+Ctrl+Alt+Right";
        "Window Quick Tile Top" = "Meta+Ctrl+Alt+Up";
        "Window Close" = "Meta+Q";
        "Window Fullscreen" = "Meta+M";
        "Window Move Center" = "Ctrl+Alt+C";
      };

      ksmserver."Lock Session" = [
        "Meta+L"
        "Meta+Shift+Q"
      ];
      ksmserver."Log Out" = [
        "Ctrl+Alt+Del"
        "Meta+Backspace"
      ];

      org_kde_powerdevil."Turn Off Screen" = "Meta+Shift+L";
      org_kde_powerdevil.powerProfile = [
        "Battery"
        "Meta+B"
      ];

      plasmashell = {
        "activate application launcher" = [
          "Meta"
          "Alt+F1"
        ];
        "activate task manager entry 1" = [ ];
        "activate task manager entry 2" = [ ];
        "activate task manager entry 3" = [ ];
        "activate task manager entry 4" = [ ];
        "activate task manager entry 5" = [ ];
        "activate task manager entry 6" = [ ];
        "activate task manager entry 7" = [ ];
        "activate task manager entry 8" = [ ];
        "activate task manager entry 9" = [ ];
        clipboard_action = "Meta+Ctrl+X";
        cycle-panels = "Meta+Alt+P";
        "manage activities" = [ ];
        "next activity" = [ ];
        "previous activity" = [ ];
        show-on-mouse-pos = "Meta+V";
        "switch to next activity" = [ ];
        "switch to previous activity" = [ ];
        "toggle do not disturb" = "Meta+Shift+N";
      };

      "services/plasma-notifications-window.desktop"._launch = "Meta+N";
      "services/brave-browser.desktop"._launch = "Meta+Shift+B";
      "services/camunda-modeler.desktop"._launch = "Meta+Shift+U";
      "services/code.desktop"._launch = "Meta+Shift+C";
      "services/kitty.desktop"._launch = "Meta+Return";
      "services/com.obsproject.Studio.desktop"._launch = "Meta+Shift+R";
      "services/com.rtosta.zapzap.desktop"._launch = "Meta+Shift+W";
      "services/dev.zed.Zed.desktop"._launch = "Meta+Shift+Z";
      "services/vesktop.desktop"._launch = "Meta+Shift+D";
      "services/org.kde.dolphin.desktop"._launch = "Meta+Shift+F";
      "services/obsidian.desktop"._launch = "Meta+Shift+O";
      "services/org.kde.krunner.desktop"._launch = [
        "Alt+Space"
        "Meta+R"
      ];
      "services/org.kde.spectacle.desktop".ActiveWindowScreenShot = "Meta+Print";
      "services/org.kde.spectacle.desktop".FullScreenScreenShot = "Print";
      "services/org.kde.spectacle.desktop"._launch = [ ];
      "services/org.kde.spectacle.desktop".RectangularRegionScreenShot = [
        "Meta+S"
        "Meta+Shift+Print"
      ];
      "services/org.telegram.desktop.desktop"._launch = "Meta+Shift+T";
      "services/plasma-manager-commands.desktop".clear-notifications = "Meta+Shift+Backspace";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-1 = "Meta+Ctrl+1";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-2 = "Meta+Ctrl+2";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-3 = "Meta+Ctrl+3";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-4 = "Meta+Ctrl+4";
      "services/postman.desktop"._launch = "Meta+Shift+P";
      "services/steam.desktop"._launch = "Meta+Shift+S";
      "services/systemsettings.desktop"._launch = "Meta+,";
      "services/kcm_kscreen.desktop"._launch = "Meta+P";
    };
  };
}
