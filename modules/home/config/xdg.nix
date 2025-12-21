{ pkgs, config, ... }:
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
  };
}
