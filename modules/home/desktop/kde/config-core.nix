{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma.configFile = {
    "powerdevilrc"."AC/Display".LockBeforeTurnOffDisplay = true;

    ksmserverrc.General.loginMode = "emptySession";

    kcminputrc = {
      "Libinput/1267/12717/ELAN2841:00 04F3:31AD Touchpad".NaturalScroll = true;
      "Libinput/1267/12868/ELAN079C:00 04F3:3244 Touchpad".NaturalScroll = true;
      Mouse.cursorTheme = "Bibata-Modern-Ice";
    };

    kded5rc = {
      Module-browserintegrationreminder.autoload = false;
      Module-device_automounter.autoload = false;
    };

    kdeglobals = {
      KDE.contrast = 7;
      General = {
        AccentColor = "203,166,247";
        BrowserApplication = "brave-browser.desktop";
        TerminalApplication = "kitty";
        TerminalService = "kitty.desktop";
        fixed = "JetBrainsMono Nerd Font Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        font = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        menuFont = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        smallestReadableFont = "Inter Variable,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        toolBarFont = "Inter Variable,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      };
      Icons.Theme = "Papirus-Dark";
    };
  };
}
