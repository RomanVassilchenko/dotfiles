{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma.configFile = {
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
        fadeEnabled = false;
        slideEnabled = false;
        squashEnabled = false;
        maximizeEnabled = false;
        overviewEnabled = false;

        blurEnabled = false;
        contrastEnabled = false;
        translucencyEnabled = false;
        dimscreenEnabled = false;
        screenedgeEnabled = false;

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
        InactiveCornerRadius = 12;
        InactiveOutlineAlpha = 0;
        InactiveSecondOutlineThickness = 0;
        OutlineThickness = 1;
        SecondOutlineThickness = 0;
        Size = 12;
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
        screenDefaultLayout = ":spiral";
        screenGapBetween = 6;
        screenGapBottom = 6;
        screenGapLeft = 6;
        screenGapRight = 6;
        screenGapTop = 6;
        spiralLayoutOrder = 1;
        tileLayoutOrder = 4;
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
  };
}
