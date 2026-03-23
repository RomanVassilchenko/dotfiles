# Noctalia shell wrapper — Catppuccin Mocha theme, adapted from vimjoyer's nixconf
# https://github.com/vimjoyer/nixconf/blob/main/modules/wrappedPrograms/noctalia/noctalia.nix
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;

        env = {
          "NOCTALIA_CACHE_DIR" = "/tmp/noctalia-cache/";
        };

        # Catppuccin Mocha palette mapped to Material Design tokens
        colors = {
          mError = "#f38ba8"; # red
          mHover = "#94e2d5"; # teal
          mOnError = "#1e1e2e"; # base
          mOnHover = "#1e1e2e"; # base
          mOnPrimary = "#1e1e2e"; # base
          mOnSecondary = "#1e1e2e"; # base
          mOnSurface = "#cdd6f4"; # text
          mOnSurfaceVariant = "#bac2de"; # subtext1
          mOnTertiary = "#1e1e2e"; # base
          mOutline = "#6c7086"; # overlay0
          mPrimary = "#cba6f7"; # mauve
          mSecondary = "#89b4fa"; # blue
          mShadow = "#11111b"; # crust
          mSurface = "#1e1e2e"; # base
          mSurfaceVariant = "#45475a"; # surface1
          mTertiary = "#74c7ec"; # sapphire
        };

        settings = {
          settingsVersion = 32;

          appLauncher = {
            customLaunchPrefix = "";
            customLaunchPrefixEnabled = false;
            enableClipPreview = true;
            enableClipboardHistory = false;
            iconMode = "tabler";
            pinnedExecs = [ ];
            position = "center";
            showCategories = true;
            sortByMostUsed = true;
            terminalCommand = "wezterm start --";
            useApp2Unit = false;
            viewMode = "list";
          };

          audio = {
            cavaFrameRate = 30;
            externalMixer = "pavucontrol";
            mprisBlacklist = [ ];
            preferredPlayer = "";
            visualizerType = "linear";
            volumeOverdrive = false;
            volumeStep = 5;
          };

          bar = {
            capsuleOpacity = 1;
            density = "comfortable";
            exclusive = true;
            floating = false;
            marginHorizontal = 0.25;
            marginVertical = 0.25;
            monitors = [ ];
            outerCorners = true;
            position = "left";
            showCapsule = false;
            showOutline = false;
            transparent = false;
            widgets = {
              center = [ ];
              left = [
                {
                  colorizeDistroLogo = true;
                  colorizeSystemIcon = "tertiary";
                  customIconPath = "";
                  enableColorization = true;
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  enableScrollWheel = true;
                  followFocusedScreen = false;
                  hideUnoccupied = true;
                  id = "Workspace";
                  labelMode = "none";
                  showApplications = false;
                  showLabelsOnlyWhenOccupied = true;
                }
              ];
              right = [
                {
                  hideWhenZero = false;
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                }
                { id = "PowerProfile"; }
                {
                  displayMode = "alwaysHide";
                  id = "Volume";
                }
                {
                  deviceNativePath = "";
                  displayMode = "alwaysShow";
                  hideIfNotDetected = true;
                  id = "Battery";
                  showNoctaliaPerformance = false;
                  showPowerProfiles = false;
                  warningThreshold = 20;
                }
                {
                  displayMode = "alwaysHide";
                  id = "Microphone";
                }
                {
                  displayMode = "forceOpen";
                  id = "KeyboardLayout";
                }
                {
                  customFont = "";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm - dd MM";
                  id = "Clock";
                  useCustomFont = false;
                  usePrimaryColor = true;
                }
                {
                  blacklist = [ ];
                  colorizeIcons = false;
                  drawerEnabled = true;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [ ];
                }
              ];
            };
          };

          brightness = {
            brightnessStep = 5;
            enableDdcSupport = false;
            enforceMinimum = true;
          };

          general = {
            allowPanelsOnScreenWithoutBar = true;
            animationDisabled = false;
            animationSpeed = 1;
            boxRadiusRatio = 1;
            compactLockScreen = false;
            dimmerOpacity = 0.15;
            enableShadows = true;
            forceBlackScreenCorners = false;
            iRadiusRatio = 1;
            language = "";
            lockOnSuspend = true;
            radiusRatio = 1;
            scaleRatio = 1;
            screenRadiusRatio = 1;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            showHibernateOnLockScreen = false;
            showScreenCorners = false;
            showSessionButtonsOnLockScreen = true;
          };

          location = {
            analogClockInCalendar = false;
            firstDayOfWeek = -1;
            showCalendarEvents = true;
            showCalendarWeather = true;
            showWeekNumberInCalendar = false;
            use12hourFormat = false;
            useFahrenheit = false;
            weatherEnabled = true;
            weatherShowEffects = true;
          };

          network = {
            wifiEnabled = true;
          };

          notifications = {
            backgroundOpacity = 1;
            criticalUrgencyDuration = 15;
            enableKeyboardLayoutToast = true;
            enabled = true;
            location = "top_right";
            lowUrgencyDuration = 8;
            monitors = [ ];
            normalUrgencyDuration = 8;
            overlayLayer = true;
            respectExpireTimeout = false;
            sounds = {
              criticalSoundFile = "";
              enabled = false;
              excludedApps = "discord,firefox,chrome,chromium,edge";
              lowSoundFile = "";
              normalSoundFile = "";
              separateSounds = false;
              volume = 0.5;
            };
          };

          osd = {
            autoHideMs = 3000;
            backgroundOpacity = 1;
            enabled = true;
            enabledTypes = [
              0
              1
              2
              4
            ];
            location = "bottom";
            monitors = [ ];
            overlayLayer = true;
          };

          screenRecorder = {
            audioCodec = "opus";
            audioSource = "default_output";
            colorRange = "limited";
            directory = "/home/romanv/Videos";
            frameRate = 60;
            quality = "very_high";
            showCursor = true;
            videoCodec = "h264";
            videoSource = "portal";
          };

          sessionMenu = {
            countdownDuration = 10000;
            enableCountdown = true;
            largeButtonsStyle = false;
            position = "center";
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
            ];
            showHeader = true;
          };

          systemMonitor = {
            cpuCriticalThreshold = 90;
            cpuPollingInterval = 3000;
            cpuWarningThreshold = 80;
            criticalColor = "";
            diskCriticalThreshold = 90;
            diskPollingInterval = 3000;
            diskWarningThreshold = 80;
            enableDgpuMonitoring = false;
            gpuCriticalThreshold = 90;
            gpuPollingInterval = 3000;
            gpuWarningThreshold = 80;
            memCriticalThreshold = 90;
            memPollingInterval = 3000;
            memWarningThreshold = 80;
            networkPollingInterval = 3000;
            tempCriticalThreshold = 90;
            tempPollingInterval = 3000;
            tempWarningThreshold = 80;
            useCustomColors = false;
            warningColor = "";
          };

          # Set individual templates to true to let noctalia manage those app configs
          templates = {
            alacritty = false;
            cava = false;
            code = false;
            discord = false;
            emacs = false;
            enableUserTemplates = false;
            foot = false;
            fuzzel = false;
            ghostty = false;
            gtk = false;
            helix = false;
            hyprland = false;
            kcolorscheme = false;
            kitty = false;
            mango = false;
            niri = false;
            pywalfox = false;
            qt = false;
            spicetify = false;
            telegram = false;
            vicinae = false;
            walker = false;
            wezterm = false;
            yazi = false;
            zed = false;
          };

          ui = {
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
            fontDefault = "Inter Variable";
            fontDefaultScale = 1;
            fontFixed = "JetBrainsMono Nerd Font";
            fontFixedScale = 1;
            panelBackgroundOpacity = 1;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
            tooltipsEnabled = true;
            wifiDetailsViewMode = "grid";
          };

          wallpaper = {
            enabled = false;
          };
        };
      };
    };
}
