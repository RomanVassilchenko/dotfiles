{
  config,
  pkgs,
  inputs,
  host,
  pkgs-stable,
  ...
}:
let
  dotfiles = config.dotfiles;
  userName = dotfiles.user.name;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit
        inputs
        host
        dotfiles
        pkgs-stable
        ;
      username = userName;
    };
    users.${userName} = {
      imports = [ ../../home ];
      home = {
        username = userName;
        homeDirectory = dotfiles.user.homeDirectory;
        stateVersion = "23.11";
      };
    };
  };
  users.mutableUsers = true;
  users.users.${userName} = {
    isNormalUser = true;
    description = dotfiles.user.gitName;
    extraGroups = [
      "adbusers"
      "docker"
      "i2c"
      "input"
      "kvm"
      "libvirtd"
      "lp"
      "networkmanager"
      "plugdev"
      "scanner"
      "vboxusers"
      "video"
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInNKbTTbxK433xEXs5A3az+j7z9bBxdgPQn6BhiOgnq roman.vassilchenko.work@gmail.com"
    ];
  };
  nix.settings.allowed-users = [ userName ];
}
