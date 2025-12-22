{ pkgs, config, lib, isServer, ... }:
{
  # Add /usr/local/bin to PATH for dot CLI and other local binaries
  home.sessionPath = [ "/usr/local/bin" ];

  # XDG-compliant environment variables
  home.sessionVariables = {
    # dotnet
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";

    # gnupg
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";

    # go
    GOPATH = "${config.xdg.dataHome}/go";

    # npm
    NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "\${XDG_RUNTIME_DIR}/npm";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
      };
    };

    # Catppuccin Mocha theme for Prism Launcher (Minecraft)
    # After rebuild, select theme in Prism Launcher: Settings > Launcher > User Interface > Widgets: Catppuccin Mocha
    dataFile = lib.mkIf (!isServer) {
      "PrismLauncher/themes/Catppuccin-Mocha/theme.json".text = builtins.toJSON {
        colors = {
          AlternateBase = "#1e1e2e";
          Base = "#181825";
          BrightText = "#bac2de";
          Button = "#313244";
          ButtonText = "#cdd6f4";
          Highlight = "#cba6f7"; # Changed to mauve for consistency
          HighlightedText = "#1e1e2e";
          Link = "#cba6f7"; # Changed to mauve
          Text = "#cdd6f4";
          ToolTipBase = "#313244";
          ToolTipText = "#cdd6f4";
          Window = "#1e1e2e";
          WindowText = "#bac2de";
          fadeAmount = 0.5;
          fadeColor = "#6c7086";
        };
        logColors = {
          Launcher = "#cba6f7"; # mauve
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
