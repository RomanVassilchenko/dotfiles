{
  dotfiles = {
    host = {
      profile = "server";
      system = "x86_64-linux";
      gpuProfile = "amd";
      deviceType = "server";
    };

    locale = {
      keyboardLayout = "us";
      consoleKeyMap = "us";
      timeZone = "Asia/Almaty";
      defaultLocale = "en_US.UTF-8";
    };
  };

  features.stylix.enable = true;
}
