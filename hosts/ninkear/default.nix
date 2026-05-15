{
  imports = [
    ./hardware.nix
  ];

  dotfiles = {
    host = {
      profile = "server";
      system = "x86_64-linux";
      gpuProfile = "amd";
      deviceType = "server";
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
      keyboardLayout = "us";
      consoleKeyMap = "us";
      timeZone = "Asia/Almaty";
      defaultLocale = "en_US.UTF-8";
    };

    paths.dotfiles = "/home/romanv/dotfiles";
  };

  features.stylix.enable = true;
}
