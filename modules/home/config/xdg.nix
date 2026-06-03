{
  config,
  dotfiles,
  lib,
  ...
}:
let
  desktopEnable = dotfiles.features.desktop.enable;
in
{
  home.sessionPath = [ "/usr/local/bin" ];

  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "code --wait";
    SUDO_EDITOR = "micro";
    COLORTERM = "truecolor";

    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";

    ANDROID_USER_HOME = "${config.xdg.dataHome}/android";

    CARGO_HOME = "${config.xdg.dataHome}/cargo";

    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";

    DOCKER_CONFIG = "${config.xdg.configHome}/docker";

    GNUPGHOME = "${config.xdg.dataHome}/gnupg";

    GOPATH = "${config.xdg.dataHome}/go";

    GTK2_RC_FILES = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";

    NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "\${XDG_RUNTIME_DIR}/npm";

    PULSE_COOKIE = "${config.xdg.configHome}/pulse/cookie";

    XCURSOR_PATH = "${config.xdg.dataHome}/icons:/usr/share/icons";
  };

  xresources.path = lib.mkIf desktopEnable "${config.xdg.configHome}/X11/xresources";

  xdg = {
    enable = true;
    mime.enable = true;
    userDirs = {
      enable = true;
      setSessionVariables = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      projects = "$HOME/Projects";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };

    configFile = lib.mkIf desktopEnable {
      "gtk-2.0/gtkrc".text = ''
        gtk-enable-animations=1
        gtk-theme-name="${config.gtk.theme.name}"
        gtk-primary-button-warps-slider=1
        gtk-toolbar-style=3
        gtk-menu-images=1
        gtk-button-images=1
        gtk-cursor-blink-time=1000
        gtk-cursor-blink=1
        gtk-cursor-theme-size=${toString config.gtk.cursorTheme.size}
        gtk-cursor-theme-name="${config.gtk.cursorTheme.name}"
        gtk-sound-theme-name="ocean"
        gtk-icon-theme-name="${config.gtk.iconTheme.name}"
        gtk-font-name="${config.gtk.font.name} ${toString config.gtk.font.size}"
      '';
    };

    dataFile = lib.mkIf dotfiles.features.desktop.enable {
      "PrismLauncher/themes/Catppuccin-Mocha/theme.json".text = builtins.toJSON {
        colors = {
          AlternateBase = "#1e1e2e";
          Base = "#181825";
          BrightText = "#bac2de";
          Button = "#313244";
          ButtonText = "#cdd6f4";
          Highlight = "#cba6f7";
          HighlightedText = "#1e1e2e";
          Link = "#cba6f7";
          Text = "#cdd6f4";
          ToolTipBase = "#313244";
          ToolTipText = "#cdd6f4";
          Window = "#1e1e2e";
          WindowText = "#bac2de";
          fadeAmount = 0.5;
          fadeColor = "#6c7086";
        };
        logColors = {
          Launcher = "#cba6f7";
          Error = "#f38ba8";
          Warning = "#f9e2af";
          Debug = "#a6e3a1";
          FatalHighlight = "#f38ba8";
          Fatal = "#181825";
        };
        name = "Catppuccin Mocha";
        widgets = "Fusion";
      };

      "PrismLauncher/themes/Catppuccin-Mocha/themeStyle.css".text = ''
        /* Catppuccin Mocha theme for Prism Launcher */
        QToolTip {
          color: #cdd6f4;
          background-color: #313244;
          border: 1px solid #313244;
        }
      '';

      "PrismLauncher/themes/Catppuccin-Mocha/resources/.keep".text = "";
    };
  };
}
