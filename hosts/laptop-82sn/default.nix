{
  dotfiles = {
    host = {
      profile = "workstation";
      system = "x86_64-linux";
      gpuProfile = "amd";
      deviceType = "laptop";
    };

    locale = {
      keyboardLayout = "us,ru";
      consoleKeyMap = "us";
      timeZone = "Asia/Almaty";
      defaultLocale = "en_US.UTF-8";
    };
  };

  features = {
    communication.enable = true;
    desktop.enable = true;
    development.enable = true;
    kde.enable = true;
    productivity.enable = true;
    stylix.enable = true;
    work.enable = true;

    apps = {
      bitwarden.enable = true;
      bitwarden.autostart = true;
      telegram.autostart = true;
      zapzap.autostart = true;
    };
  };
}
