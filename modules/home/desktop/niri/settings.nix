# Niri wayland compositor — home-manager configuration
# Adapted from vimjoyer's nixconf: https://github.com/vimjoyer/nixconf
#
# Keybindings use Mod (Super/Meta) as the modifier.
# Noctalia shell is launched at startup as the bar/launcher/notification daemon.
# Mod+S toggles the noctalia app launcher.
#
# NOTE: binds use config.lib.niri.actions helpers from the niri home-manager module.
# If you see type errors, check: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.niri
{
  self,
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
in
{
  programs.niri = {
    enable = true;

    settings = {
      prefer-no-csd = true;

      input = {
        keyboard = {
          xkb = {
            layout = vars.keyboardLayout;
            options = "grp:alt_shift_toggle,caps:escape";
          };
          repeat-rate = 40;
          repeat-delay = 250;
        };
        touchpad = {
          natural-scroll = true;
          tap = true;
        };
        mouse.accel-profile = "flat";
        focus-follows-mouse.max-scroll-amount = "0%";
      };

      layout = {
        gaps = 5;
        focus-ring = {
          width = 2;
          active.color = "#cba6f7"; # Catppuccin Mocha mauve
          inactive.color = "#313244"; # surface0
        };
      };

      # Things to launch when niri starts — niri-specific only.
      # General apps (Telegram, Bitwarden, etc.) are Plasma-only via OnlyShowIn=KDE; in their .desktop files.
      spawn-at-startup = [
        # Noctalia: bar + launcher + notifications + system controls
        { command = [ noctalia ]; }
        # Solid Catppuccin Mocha base color as desktop background
        # Replace with: { command = [ "${lib.getExe pkgs.swaybg}" "-i" "/path/to/image.jpg" "-m" "fill" ]; }
        {
          command = [
            "${lib.getExe pkgs.swaybg}"
            "-c"
            "#1e1e2e"
          ];
        }
        # XWayland compatibility for apps that don't support Wayland natively
        { command = [ "${lib.getExe pkgs.xwayland-satellite}" ]; }
      ];

      environment = {
        DISPLAY = ":0"; # set by xwayland-satellite
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
      };

      binds = with config.lib.niri.actions; {
        # Terminal
        "Mod+Return".action = spawn "wezterm";

        # Window management
        "Mod+Q".action = close-window;
        "Mod+F".action = maximize-column;
        "Mod+G".action = fullscreen-window;
        "Mod+Shift+F".action = toggle-window-floating;
        "Mod+C".action = center-column;

        # Focus navigation (hjkl + arrows)
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+K".action = focus-window-up;
        "Mod+J".action = focus-window-down;
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;

        # Move windows
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+J".action = move-window-down;

        # Workspaces
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+Shift+1".action = move-column-to-workspace 1;
        "Mod+Shift+2".action = move-column-to-workspace 2;
        "Mod+Shift+3".action = move-column-to-workspace 3;
        "Mod+Shift+4".action = move-column-to-workspace 4;
        "Mod+Shift+5".action = move-column-to-workspace 5;

        # Noctalia app launcher
        "Mod+S".action = spawn noctalia "ipc" "call" "launcher" "toggle";

        # Resize
        "Mod+Ctrl+H".action = set-column-width "-5%";
        "Mod+Ctrl+L".action = set-column-width "+5%";
        "Mod+Ctrl+J".action = set-window-height "-5%";
        "Mod+Ctrl+K".action = set-window-height "+5%";

        # Audio
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn "sh" "-c" "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn "sh" "-c" "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        # Mic mute (for virtual mic — same toggle as in Plasma config)
        "Mod+V".action = spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        # Screenshots (grim + slurp → clipboard)
        "Mod+Ctrl+S".action =
          spawn "sh" "-c"
            "${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy";
        "Mod+Shift+S".action =
          spawn "sh" "-c"
            "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";

        # Session
        "Mod+Escape".action = quit;
      };
    };
  };

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    swappy
    swaybg
    xwayland-satellite
  ];
}
