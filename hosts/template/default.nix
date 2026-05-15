{
  imports = [
    ./hardware.nix
  ];

  dotfiles = {
    host = {
      profile = "workstation";
      system = "x86_64-linux";
      gpuProfile = "intel";
      deviceType = "laptop";
    };

    user = {
      name = "youruser";
      gitName = "Jane Doe";
      gitEmail = "jane@example.com";
      authorizedKeys = [ ];
    };

    locale = {
      keyboardLayout = "us";
      consoleKeyMap = "us";
      timeZone = "UTC";
      defaultLocale = "en_US.UTF-8";
    };
  };

  features = {
    development.enable = true;
    kde.enable = true;
    productivity.enable = true;
    stylix.enable = true;
  };
}
