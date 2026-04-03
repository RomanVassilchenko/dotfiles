{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma = {
    panels = [
      {
        location = "top";
        height = 32;
        floating = false;
        hiding = "none";
        screen = 0;
        opacity = "translucent";

        widgets = [
          {
            name = "luisbocanegra.panel.colorizer";
            config = {
              General = {
                hideWidget = true;

                bgColor = "#1e1e2e";
                bgColorEnabled = true;
                bgContrastFixEnabled = false;
                bgOpacity = 0.75;
                blurBehindEnabled = true;

                fgColorEnabled = true;
                fgColor = "#cdd6f4";

                cornerRadius = 12;
                enableCustomRadius = true;

                marginRules = "0,6,0,6";
                panelOutlineColorEnabled = false;

                panelSpacing = 4;
                widgetBgEnabled = false;

                shadowColorEnabled = true;
                shadowColor = "#11111b";
                shadowSize = 2;
              };
            };
          }

          {
            name = "org.kde.plasma.weather";
            config = {
              Appearance = {
                showPressureInTooltip = true;
                showTemperatureInCompactMode = true;
                autoFontAndSize = true;
              };
              Units = {
                pressureUnit = 5008;
                speedUnit = 9000;
                temperatureUnit = 6001;
                visibilityUnit = 2007;
              };
              WeatherStation = {
                placeDisplayName = "Astana, Kazakhstan, KZ";
                placeInfo = "Astana, Kazakhstan, KZ|1526273";
                provider = "bbcukmet";
              };
            };
          }

          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                autoFontAndSize = true;
                customDateFormat = "ddd d MMM";
                dateDisplayFormat = "BesideTime";
                dateFormat = "custom";
                use24hFormat = 2;
              };
            };
          }

          {
            name = "org.kde.plasma.panelspacer";
          }

          {
            name = "org.kde.plasma.pager";
            config = {
              General = {
                displayedText = "Name";
                showOnlyCurrentScreen = false;
                showWindowOutlines = false;
                wrapPage = true;
              };
            };
          }

          {
            name = "org.kde.plasma.panelspacer";
          }

          {
            name = "com.romanv.displaytoggle";
          }

          {
            name = "org.kde.plasma.vpnmanager";
          }

          {
            systemTray = {
              items = {
                shown = [
                  "org.kde.plasma.volume"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.keyboardlayout"
                  "org.kde.kdeconnect"
                ];
                hidden = [
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.keyboardindicator"
                  "org.kde.plasma.mediacontroller"
                  "org.kde.plasma.devicenotifier"
                  "org.kde.kscreen"
                  "org.kde.plasma.cameraindicator"
                  "org.kde.plasma.manage-inputmethod"
                  "org.kde.plasma.weather"
                ];
              };
            };
          }

          {
            name = "org.kde.plasma.lock_logout";
            config = {
              General = {
                show_lockScreen = false;
                show_requestLogoutScreen = false;
                show_requestShutDown = true;
              };
            };
          }
        ];
      }
    ];
  };
}
