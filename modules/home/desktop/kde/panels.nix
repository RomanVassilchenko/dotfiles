{
  programs.plasma = {
    panels = [
      {
        location = "top";
        height = 32;
        floating = false;
        hiding = "none";
        screen = "all";
        opacity = "translucent";

        widgets = [
          # Panel Colorizer - must be first for proper styling
          {
            name = "luisbocanegra.panel.colorizer";
            config = {
              General = {
                # Hide widget icon from panel
                hideWidget = true;

                # Catppuccin Mocha base colors
                bgColor = "#1e1e2e"; # Base
                bgColorEnabled = true;
                bgContrastFixEnabled = false;
                bgOpacity = 0.75;
                blurBehindEnabled = true;

                # Foreground styling
                fgColorEnabled = true;
                fgColor = "#cdd6f4"; # Text color

                # Rounded corners for floating look
                cornerRadius = 12;
                enableCustomRadius = true;

                # Margins and spacing
                marginRules = "0,6,0,6";
                panelOutlineColorEnabled = false;

                # Panel spacing
                panelSpacing = 4;
                widgetBgEnabled = false;

                # Shadow for depth
                shadowColorEnabled = true;
                shadowColor = "#11111b";
                shadowSize = 2;
              };
            };
          }

          # Left side - Weather and Clock (contextual info)
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

          # First spacer (expands to push center widgets)
          {
            name = "org.kde.plasma.panelspacer";
          }

          # Center - Desktop pager (focal navigation)
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

          # Second spacer (expands to push right widgets)
          {
            name = "org.kde.plasma.panelspacer";
          }

          # VPN Manager widget
          {
            name = "org.kde.plasma.vpnmanager";
          }

          # System tray - all system controls inside
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
        ];
      }
    ];
  };
}
