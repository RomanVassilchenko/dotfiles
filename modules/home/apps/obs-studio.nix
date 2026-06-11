{
  dotfiles,
  lib,
  pkgs-stable,
  appConfig,
  ...
}:
lib.mkIf dotfiles.features.apps.obsStudio.enable {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs-stable.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-move-transition
      obs-composite-blur
      # obs-backgroundremoval
      droidcam-obs
    ];
  };

  xdg.configFile = {
    "autostart/com.obsproject.Studio.desktop" = lib.mkIf (appConfig.obsStudio.autostart or false) {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=OBS Studio
        Comment=Live streaming and recording studio
        Exec=${pkgs-stable.obs-studio}/bin/obs
        Icon=com.obsproject.Studio
        Terminal=false
        Categories=AudioVideo;Recorder;Video;
        StartupWMClass=obs
      '';
    };

    "obs-studio/themes/Catppuccin.obt".source = ./obs-studio/themes/Catppuccin.obt;
    "obs-studio/themes/Catppuccin_Mocha.ovt".source = ./obs-studio/themes/Catppuccin_Mocha.ovt;
  };
}
