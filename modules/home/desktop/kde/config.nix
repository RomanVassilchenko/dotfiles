{ pkgs, ... }:
{
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

      kwin.KrohnkiteFocusDown = "Meta+Down";
      kwin.KrohnkiteFocusLeft = "Meta+Left";
      kwin.KrohnkiteFocusRight = "Meta+Right";
      kwin.KrohnkiteFocusUp = "Meta+Up";
      kwin.KrohnkiteGrowHeight = "Meta+Ctrl+Down";
      kwin.KrohnkitegrowWidth = "Meta+Ctrl+Right";
      kwin.KrohnkiteIncrease = "Meta+I";
      kwin.KrohnkiteNextLayout = "Meta+Space";
      kwin.KrohnkitePreviousLayout = "Meta+Shift+Space";
      kwin.KrohnkiteSetMaster = "Meta+Shift+Return";
      kwin.KrohnkiteShiftDown = "Meta+Shift+Down";
      kwin.KrohnkiteShiftLeft = "Meta+Shift+Left";
      kwin.KrohnkiteShiftRight = "Meta+Shift+Right";
      kwin.KrohnkiteShiftUp = "Meta+Shift+Up";
      kwin.KrohnkiteShrinkHeight = "Meta+Ctrl+Up";
      kwin.KrohnkiteShrinkWidth = "Meta+Ctrl+Left";
      kwin.KrohnkiteToggleFloat = "Meta+F";

      kwin."Move with Window to Desktop 1" = "Meta+!";
      kwin."Move with Window to Desktop 2" = "Meta+@";
      kwin."Move with Window to Desktop 3" = "Meta+#";
      kwin."Move with Window to Desktop 4" = "Meta+$";
      kwin."Switch to Desktop 1" = [
        "Meta+1"
        "Meta+Num+1"
      ];
      kwin."Switch to Desktop 2" = [
        "Meta+2"
        "Meta+Num+2"
      ];
      kwin."Switch to Desktop 3" = [
        "Meta+3"
        "Meta+Num+3"
      ];
      kwin."Switch to Desktop 4" = [
        "Meta+4"
        "Meta+Num+4"
      ];
      kwin."Switch to Next Desktop" = "Meta+PgDown";
      kwin."Switch to Previous Desktop" = "Meta+PgUp";
      kwin."Toggle Tiling" = [ ];
      kwin."Window Close" = "Meta+Q";
      kwin."Window Fullscreen" = "Meta+M";
      kwin."Window Move Center" = "Ctrl+Alt+C";

      ksmserver."Lock Session" = [
        "Meta+L"
        "Meta+Shift+Q"
      ];

      org_kde_powerdevil."Turn Off Screen" = "Meta+Shift+L";
      org_kde_powerdevil.powerProfile = [
        "Battery"
        "Meta+B"
      ];

      plasmashell."activate application launcher" = [
        "Meta"
        "Alt+F1"
      ];
      plasmashell.clipboard_action = "Meta+Ctrl+X";
      plasmashell.cycle-panels = "Meta+Alt+P";
      plasmashell.show-on-mouse-pos = "Meta+V";

      "services/brave-browser.desktop"._launch = "Meta+Shift+B";
      "services/camunda-modeler.desktop"._launch = "Meta+Shift+U";
      "services/code.desktop"._launch = "Meta+Shift+C";
      yakuake."toggle-window-state" = "F12";
      "services/org.kde.konsole.desktop"._launch = "Meta+Return";
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
      "services/org.kde.spectacle.desktop".RectangularRegionScreenShot = [
        "Meta+S"
        "Meta+Shift+Print"
      ];
      "services/org.telegram.desktop.desktop"._launch = "Meta+Shift+T";
      "services/plasma-manager-commands.desktop".clear-notifications = "Meta+Shift+Backspace";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-1 = "Meta+!";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-2 = "Meta+@";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-3 = "Meta+#";
      "services/plasma-manager-commands.desktop".move-window-and-focus-to-desktop-4 = "Meta+$";
      "services/postman.desktop"._launch = "Meta+Shift+P";
      "services/steam.desktop"._launch = "Meta+Shift+S";
    };

    configFile = {
      "powerdevilrc"."AC/Display".LockBeforeTurnOffDisplay = true;

      ksmserverrc.General.loginMode = "emptySession";

      kcminputrc."Libinput/1267/12717/ELAN2841:00 04F3:31AD Touchpad".NaturalScroll = true;
      kcminputrc."Libinput/1267/12868/ELAN079C:00 04F3:3244 Touchpad".NaturalScroll = true;
      kcminputrc.Mouse.cursorTheme = "Bibata-Modern-Ice";

      kded5rc.Module-browserintegrationreminder.autoload = false;
      kded5rc.Module-device_automounter.autoload = false;

      kdeglobals.KDE.contrast = 7;
      kdeglobals.General.AccentColor = "203,166,247";
      kdeglobals.General.BrowserApplication = "brave-browser.desktop";
      kdeglobals.General.TerminalApplication = "konsole";
      kdeglobals.General.TerminalService = "org.kde.konsole.desktop";
      kdeglobals.General.fixed = "JetBrainsMono Nerd Font Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      kdeglobals.General.font = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      kdeglobals.General.menuFont = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      kdeglobals.General.smallestReadableFont = "Inter Variable,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      kdeglobals.General.toolBarFont = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      kdeglobals.Icons.Theme = "Papirus-Dark";

      kiorc.Confirmations.ConfirmEmptyTrash = false;
      klipperrc.General.IgnoreImages = true;
      klipperrc.General.MaxClipItems = 100;
      krunnerrc.General.ActivateWhenTypingOnDesktop = true;
      krunnerrc.General.FreeFloating = true;
      ksplashrc.KSplash.Theme = "Catppuccin-Mocha-Mauve";
      kwalletrc.Wallet."First Use" = false;

      kwinrc.Desktops.Id_1 = "Desktop_1";
      kwinrc.Desktops.Id_2 = "Desktop_2";
      kwinrc.Desktops.Id_3 = "Desktop_3";
      kwinrc.Desktops.Id_4 = "Desktop_4";
      kwinrc.Desktops.Name_1 = "Web";
      kwinrc.Desktops.Name_2 = "Dev";
      kwinrc.Desktops.Name_3 = "Chat";
      kwinrc.Desktops.Name_4 = "Play";
      kwinrc.Desktops.Number = 4;
      kwinrc.Desktops.Rows = 1;

      # Lightweight effects (minimal GPU cost)
      kwinrc.Plugins.fadeEnabled = true;
      kwinrc.Plugins.slideEnabled = true;
      kwinrc.Plugins.squashEnabled = true;
      kwinrc.Plugins.maximizeEnabled = true;
      kwinrc.Plugins.overviewEnabled = true;

      # Disabled effects (heavy on GPU)
      kwinrc.Plugins.blurEnabled = false;
      kwinrc.Plugins.contrastEnabled = false;
      kwinrc.Plugins.translucencyEnabled = false;
      kwinrc.Plugins.dimscreenEnabled = false;
      kwinrc.Plugins.screenedgeEnabled = false;

      # Functional plugins
      kwinrc.Plugins.desktop-cursor-moveEnabled = true;
      kwinrc.Plugins.krohnkiteEnabled = true;
      kwinrc.Plugins.kwin4_effect_shapecornersEnabled = true;
      kwinrc.Plugins.move-windows-to-desktopsEnabled = true;

      kwinrc."Effect-overview".BorderActivate = 9;

      kwinrc.NightColor.Active = false;
      kwinrc.NightColor.NightTemperature = 4500;

      kwinrc.Compositing.AnimationSpeed = 2;
      kwinrc.Compositing.Backend = "OpenGL";
      kwinrc.Compositing.GLCore = true;
      kwinrc.Compositing.LatencyPolicy = "Low";
      kwinrc.Compositing.WindowsBlockCompositing = true;

      kwinrc."Round-Corners".ActiveOutlineAlpha = 0;
      kwinrc."Round-Corners".ActiveOutlineColor = "203,166,247";
      kwinrc."Round-Corners".ActiveOutlineUseCustom = false;
      kwinrc."Round-Corners".ActiveOutlineUsePalette = true;
      kwinrc."Round-Corners".AnimationDuration = 0;
      kwinrc."Round-Corners".DisableOutlineTile = false;
      kwinrc."Round-Corners".DisableRoundTile = false;
      kwinrc."Round-Corners".InactiveCornerRadius = 8;
      kwinrc."Round-Corners".InactiveOutlineAlpha = 0;
      kwinrc."Round-Corners".InactiveSecondOutlineThickness = 0;
      kwinrc."Round-Corners".OutlineThickness = 1;
      kwinrc."Round-Corners".SecondOutlineThickness = 0;
      kwinrc."Round-Corners".Size = 8;

      kwinrc.Script-krohnkite.enableMonocleLayout = false;
      kwinrc.Script-krohnkite.enableSpiralLayout = true;
      kwinrc.Script-krohnkite.enableSpreadLayout = false;
      kwinrc.Script-krohnkite.enableStairLayout = false;
      kwinrc.Script-krohnkite.enableTileLayout = false;
      kwinrc.Script-krohnkite.floatingClass = "brave-nngceckbapebfimnlniiiahkandclblb-Default,org.kde.kcalc,org.freedesktop.impl.portal.desktop.kde,systemsettings,kcmshell5,kcmshell6,org.kde.polkit-kde-authentication-agent-1,krunner,ksplashqml,ksplashsimple,ksplashx,plasmashell,plasma-desktop,ksmserver,kded5,kded6,kwin_wayland,kwin_x11,org.kde.kdeconnect.daemon,org.kde.discover,org.kde.kwalletd5,org.kde.kwalletd6,org.kde.plasma.emojier,pavucontrol,blueman-manager,nm-connection-editor,arandr,lxappearance,nitrogen,qt5ct,qt6ct,kvantummanager,xdg-desktop-portal-kde,org.kde.plasma-systemmonitor,org.kde.kinfocenter,org.kde.plasma.settings,org.kde.kscreen.osd,kded,plasma-interactiveconsole,plasmoidviewer,xwaylandvideobridge,vlc,mpv,feh,nsxiv,imv,zenity,kdialog,pinentry-qt,gcr-prompter,spectacle,org.kde.ark,org.kde.gwenview,org.kde.okular";
      kwinrc.Script-krohnkite.floatingTitle = "Picture in picture";
      kwinrc.Script-krohnkite.layoutPerActivity = true;
      kwinrc.Script-krohnkite.layoutPerDesktop = true;
      kwinrc.Script-krohnkite.noTileBorder = false;
      kwinrc.Script-krohnkite.screenGapBetween = 6;
      kwinrc.Script-krohnkite.screenGapBottom = 6;
      kwinrc.Script-krohnkite.screenGapLeft = 6;
      kwinrc.Script-krohnkite.screenGapRight = 6;
      kwinrc.Script-krohnkite.screenGapTop = 6;
      kwinrc.Tiling.padding = 4;
      kwinrc."org.kde.kdecoration2".BorderSize = "None";
      kwinrc."org.kde.kdecoration2".BorderSizeAuto = false;

      kwinrc.Windows.DelayFocusInterval = 150;
      kwinrc.Windows.FocusPolicy = "FocusFollowsMouse";

      # Meta alone opens the application launcher
      kwinrc.ModifierOnlyShortcuts.Meta = "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu";

      kwinrulesrc."1".Description = "Hide titlebar by default";
      kwinrulesrc."1".noborder = true;
      kwinrulesrc."1".noborderrule = 3;
      kwinrulesrc."1".wmclass = ".*";
      kwinrulesrc."1".wmclasscomplete = true;
      kwinrulesrc."1".wmclassmatch = 3;

      kwinrulesrc."2".Description = "Web to Desktop 1";
      kwinrulesrc."2".desktops = "Desktop_1";
      kwinrulesrc."2".desktopsrule = 3;
      kwinrulesrc."2".types = 1;
      kwinrulesrc."2".wmclass = "brave-browser|google-chrome|xfreerdp";
      kwinrulesrc."2".wmclasscomplete = false;
      kwinrulesrc."2".wmclassmatch = 3;

      kwinrulesrc."3".Description = "Dev to Desktop 2";
      kwinrulesrc."3".desktops = "Desktop_2";
      kwinrulesrc."3".desktopsrule = 3;
      kwinrulesrc."3".types = 1;
      kwinrulesrc."3".wmclass =
        "kitty|konsole|code|Zed|dev.zed.Zed|camunda-modeler|DBeaver|Postman|com.obsproject.Studio";
      kwinrulesrc."3".wmclasscomplete = false;
      kwinrulesrc."3".wmclassmatch = 3;

      kwinrulesrc."4".Description = "Chat to Desktop 3";
      kwinrulesrc."4".desktops = "Desktop_3";
      kwinrulesrc."4".desktopsrule = 3;
      kwinrulesrc."4".types = 1;
      kwinrulesrc."4".wmclass = "org.telegram.desktop|com.rtosta.zapzap|vesktop|zoom.*|obsidian";
      kwinrulesrc."4".wmclasscomplete = false;
      kwinrulesrc."4".wmclassmatch = 3;

      kwinrulesrc."5".Description = "Games to Desktop 4";
      kwinrulesrc."5".desktops = "Desktop_4";
      kwinrulesrc."5".desktopsrule = 3;
      kwinrulesrc."5".types = 1;
      kwinrulesrc."5".wmclass = "osu!|prismlauncher|steam|Minecraft";
      kwinrulesrc."5".wmclasscomplete = false;
      kwinrulesrc."5".wmclassmatch = 3;

      kwinrulesrc."11".Description = "Picture-in-Picture: Float, Always On Top";
      kwinrulesrc."11".above = true;
      kwinrulesrc."11".aboverule = 2;
      kwinrulesrc."11".desktops = "";
      kwinrulesrc."11".desktopsrule = 2;
      kwinrulesrc."11".floatrule = 2;
      kwinrulesrc."11".ignoregeometry = false;
      kwinrulesrc."11".ignoregeometryrule = 2;
      kwinrulesrc."11".position = "1920,1080";
      kwinrulesrc."11".positionrule = 3;
      kwinrulesrc."11".size = "640,360";
      kwinrulesrc."11".sizerule = 3;
      kwinrulesrc."11".skipagerrule = 2;
      kwinrulesrc."11".skippager = true;
      kwinrulesrc."11".skiptaskbar = true;
      kwinrulesrc."11".skiptaskbarrule = 2;
      kwinrulesrc."11".title = "Picture in picture";
      kwinrulesrc."11".titlematch = 2;
      kwinrulesrc."11".types = 1;
      kwinrulesrc."11".wmclass = "brave";
      kwinrulesrc."11".wmclassmatch = 1;

      kwinrulesrc.General.count = 6;
      kwinrulesrc.General.rules = "1,2,3,4,5,11";

      kxkbrc.Layout.DisplayNames = ",";
      kxkbrc.Layout.LayoutList = "us,ru";
      kxkbrc.Layout.Use = true;
      kxkbrc.Layout.VariantList = ",";

      "plasma-applet-org.kde.plasma.battery".General.showPercentage = true;

      baloofilerc."Basic Settings"."Indexing-Enabled" = false;

      spectaclerc.GuiConfig.quitAfterSaveCopyExport = true;

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
      plasmanotifyrc.DoNotDisturb.WhenFullscreen = false;
      plasmanotifyrc.DoNotDisturb.WhenScreensMirrored = false;
      plasmanotifyrc.Notifications.PopupPosition = "TopRight";
      plasmanotifyrc.Notifications.PopupTimeout = 7000;
    };
  };
}
