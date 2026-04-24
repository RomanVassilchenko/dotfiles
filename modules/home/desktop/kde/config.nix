{
  dotfiles,
  lib,
  pkgs,
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

    configFile = {
      "powerdevilrc"."AC/Display".LockBeforeTurnOffDisplay = true;

      ksmserverrc.General.loginMode = "emptySession";

      kcminputrc = {
        "Libinput/1267/12717/ELAN2841:00 04F3:31AD Touchpad".NaturalScroll = true;
        "Libinput/1267/12868/ELAN079C:00 04F3:3244 Touchpad".NaturalScroll = true;
        Mouse.cursorTheme = "Bibata-Modern-Ice";
      };

      kded5rc = {
        Module-browserintegrationreminder.autoload = false;
        Module-device_automounter.autoload = false;
      };

      kdeglobals = {
        KDE.contrast = 7;
        General = {
          AccentColor = "203,166,247";
          BrowserApplication = "brave-browser.desktop";
          TerminalApplication = "kitty";
          TerminalService = "kitty.desktop";
          fixed = "JetBrainsMono Nerd Font Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
          font = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
          menuFont = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
          smallestReadableFont = "Inter Variable,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
          toolBarFont = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        };
        Icons.Theme = "Papirus-Dark";
      };

      kiorc.Confirmations.ConfirmEmptyTrash = false;
      klipperrc.General.IgnoreImages = true;
      klipperrc.General.MaxClipItems = 100;
      krunnerrc.General.ActivateWhenTypingOnDesktop = true;
      krunnerrc.General.FreeFloating = true;
      ksplashrc.KSplash.Theme = "Catppuccin-Mocha-Mauve";
      kwalletrc.Wallet."First Use" = false;

      kwinrc = {
        Desktops = {
          Id_1 = "Desktop_1";
          Id_2 = "Desktop_2";
          Id_3 = "Desktop_3";
          Id_4 = "Desktop_4";
          Name_1 = "Web";
          Name_2 = "Dev";
          Name_3 = "Chat";
          Name_4 = "Play";
          Number = 4;
          Rows = 1;
        };

        Plugins = {
          # Disable visual effects for a fully static desktop.
          fadeEnabled = false;
          slideEnabled = false;
          squashEnabled = false;
          maximizeEnabled = false;
          overviewEnabled = false;

          # Disabled effects (heavy on GPU)
          blurEnabled = false;
          contrastEnabled = false;
          translucencyEnabled = false;
          dimscreenEnabled = false;
          screenedgeEnabled = false;

          # Functional plugins
          desktop-cursor-moveEnabled = true;
          krohnkiteEnabled = true;
          kwin4_effect_shapecornersEnabled = true;
          move-windows-to-desktopsEnabled = true;
        };

        "Effect-overview".BorderActivate = 9;

        NightColor = {
          Active = false;
          NightTemperature = 4500;
        };

        Compositing = {
          AnimationSpeed = 0;
          Backend = "OpenGL";
          GLCore = true;
          LatencyPolicy = "Low";
          WindowsBlockCompositing = true;
        };

        "Round-Corners" = {
          ActiveOutlineAlpha = 0;
          ActiveOutlineColor = "203,166,247";
          ActiveOutlineUseCustom = false;
          ActiveOutlineUsePalette = true;
          AnimationDuration = 0;
          DisableOutlineTile = false;
          DisableRoundTile = false;
          InactiveCornerRadius = 8;
          InactiveOutlineAlpha = 0;
          InactiveSecondOutlineThickness = 0;
          OutlineThickness = 1;
          SecondOutlineThickness = 0;
          Size = 8;
        };

        Script-krohnkite = {
          enableMonocleLayout = false;
          enableSpiralLayout = true;
          enableSpreadLayout = false;
          enableStairLayout = false;
          enableTileLayout = false;
          floatingClass = "brave-nngceckbapebfimnlniiiahkandclblb-Default,org.kde.kcalc,org.freedesktop.impl.portal.desktop.kde,systemsettings,kcmshell5,kcmshell6,org.kde.polkit-kde-authentication-agent-1,krunner,ksplashqml,ksplashsimple,ksplashx,plasmashell,plasma-desktop,ksmserver,kded5,kded6,kwin_wayland,kwin_x11,org.kde.kdeconnect.daemon,org.kde.discover,org.kde.kwalletd5,org.kde.kwalletd6,org.kde.plasma.emojier,pavucontrol,blueman-manager,nm-connection-editor,arandr,lxappearance,nitrogen,qt5ct,qt6ct,kvantummanager,xdg-desktop-portal-kde,org.kde.plasma-systemmonitor,org.kde.kinfocenter,org.kde.plasma.settings,org.kde.kscreen.osd,kded,plasma-interactiveconsole,plasmoidviewer,xwaylandvideobridge,vlc,mpv,feh,nsxiv,imv,zenity,kdialog,pinentry-qt,gcr-prompter,spectacle,org.kde.ark,org.kde.gwenview,org.kde.okular";
          floatingTitle = "Picture in picture";
          layoutPerActivity = true;
          layoutPerDesktop = true;
          noTileBorder = false;
          screenGapBetween = 6;
          screenGapBottom = 6;
          screenGapLeft = 6;
          screenGapRight = 6;
          screenGapTop = 6;
        };

        Tiling.padding = 4;
        "org.kde.kdecoration2" = {
          BorderSize = "None";
          BorderSizeAuto = false;
        };

        Windows = {
          DelayFocusInterval = 150;
          FocusPolicy = "FocusFollowsMouse";
        };

        # Meta alone opens the application launcher
        ModifierOnlyShortcuts.Meta = "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu";
      };

      kwinrulesrc = {
        "1" = {
          Description = "Hide titlebar by default";
          noborder = true;
          noborderrule = 3;
          wmclass = ".*";
          wmclasscomplete = true;
          wmclassmatch = 3;
        };

        "2" = {
          Description = "Web to Desktop 1";
          desktops = "Desktop_1";
          desktopsrule = 3;
          types = 1;
          wmclass = "brave-browser|google-chrome|xfreerdp";
          wmclasscomplete = false;
          wmclassmatch = 3;
        };

        "3" = {
          Description = "Dev to Desktop 2";
          desktops = "Desktop_2";
          desktopsrule = 3;
          types = 1;
          wmclass = "kitty|code|Zed|dev.zed.Zed|camunda-modeler|DBeaver|Postman|com.obsproject.Studio";
          wmclasscomplete = false;
          wmclassmatch = 3;
        };

        "4" = {
          Description = "Chat to Desktop 3";
          desktops = "Desktop_3";
          desktopsrule = 3;
          types = 1;
          wmclass = "org.telegram.desktop|com.rtosta.zapzap|vesktop|zoom.*|obsidian";
          wmclasscomplete = false;
          wmclassmatch = 3;
        };

        "5" = {
          Description = "Games to Desktop 4";
          desktops = "Desktop_4";
          desktopsrule = 3;
          types = 1;
          wmclass = "osu!|prismlauncher|steam|Minecraft";
          wmclasscomplete = false;
          wmclassmatch = 3;
        };

        "11" = {
          Description = "Picture-in-Picture: Float, Always On Top";
          above = true;
          aboverule = 2;
          desktops = "";
          desktopsrule = 2;
          floatrule = 2;
          ignoregeometry = false;
          ignoregeometryrule = 2;
          position = "1920,1080";
          positionrule = 3;
          size = "640,360";
          sizerule = 3;
          skipagerrule = 2;
          skippager = true;
          skiptaskbar = true;
          skiptaskbarrule = 2;
          title = "Picture in picture";
          titlematch = 2;
          types = 1;
          wmclass = "brave";
          wmclassmatch = 1;
        };

        General = {
          count = 6;
          rules = "1,2,3,4,5,11";
        };
      };

      kxkbrc = {
        Layout = {
          DisplayNames = ",";
          LayoutList = "us,ru";
          Use = true;
          VariantList = ",";
        };
      };

      "plasma-applet-org.kde.plasma.battery".General.showPercentage = true;

      baloofilerc."Basic Settings"."Indexing-Enabled" = false;

      spectaclerc.GuiConfig.quitAfterSaveCopyExport = true;

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
      plasmanotifyrc = {
        DoNotDisturb.WhenFullscreen = false;
        DoNotDisturb.WhenScreensMirrored = false;
        Notifications.PopupPosition = "TopRight";
        Notifications.PopupTimeout = 4000;
      };
    };
  };
}
