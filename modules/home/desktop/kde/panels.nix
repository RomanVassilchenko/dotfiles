{
  programs.plasma = {
    panels = [
      {
        location = "top";
        height = 28;
        floating = false;
        hiding = "none";
        screen = "all";
        opacity = "translucent";

        widgets = [
          # Left side - Desktop pager (show names, fixed width)
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

          # First spacer (expands to push center widgets)
          {
            name = "org.kde.plasma.panelspacer";
          }

          # Center - Weather and Clock
          {
            name = "org.kde.plasma.weather";
            config = {
              Appearance = {
                showPressureInTooltip = true;
                showTemperatureInCompactMode = true;
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
                customDateFormat = "| ddd dd MMM yyyy |";
                dateDisplayFormat = "BesideTime";
                dateFormat = "custom";
              };
            };
          }

          # Second spacer (expands to push right widgets)
          {
            name = "org.kde.plasma.panelspacer";
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
