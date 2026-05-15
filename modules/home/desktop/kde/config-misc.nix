{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.desktop.plasma.enable {
  programs.plasma.configFile = {
    kiorc.Confirmations.ConfirmEmptyTrash = false;
    klipperrc.General.IgnoreImages = true;
    klipperrc.General.MaxClipItems = 100;
    krunnerrc.General.ActivateWhenTypingOnDesktop = true;
    krunnerrc.General.FreeFloating = true;
    ksplashrc.KSplash.Theme = "Catppuccin-Mocha-Mauve";
    kwalletrc.Wallet."First Use" = false;

    kxkbrc = {
      Layout = {
        DisplayNames = ",";
        LayoutList = "us,ru";
        Use = true;
        VariantList = ",";
      };
    };

    "plasma-applet-org.kde.plasma.battery".General.showPercentage = true;

    baloofilerc."Basic Settings"."Indexing-Enabled" = false;

    spectaclerc.GuiConfig.quitAfterSaveCopyExport = true;

    plasma-localerc.Formats.LANG = "en_US.UTF-8";
    plasmanotifyrc = {
      DoNotDisturb.WhenFullscreen = false;
      DoNotDisturb.WhenScreensMirrored = false;
      Notifications.PopupPosition = "TopRight";
      Notifications.PopupTimeout = 4000;
    };
  };
}
