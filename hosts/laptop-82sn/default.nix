{
  imports = [
    ./hardware.nix
  ];

  dotfiles = {
    host = {
      profile = "workstation";
      system = "x86_64-linux";
      gpuProfile = "amd";
      deviceType = "laptop";
    };

    user = {
      name = "romanv";
      gitName = "Roman Vassilchenko";
      gitEmail = "roman.vassilchenko.work@gmail.com";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInNKbTTbxK433xEXs5A3az+j7z9bBxdgPQn6BhiOgnq roman.vassilchenko.work@gmail.com"
      ];
    };

    locale = {
      keyboardLayout = "us,ru";
      consoleKeyMap = "us";
      timeZone = "Asia/Almaty";
      defaultLocale = "en_US.UTF-8";
    };

    paths.dotfiles = "/home/romanv/dotfiles";
  };

  features = {
    communication.enable = true;
    desktop.enable = true;
    development.enable = true;
    hardware.enable = true;
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
