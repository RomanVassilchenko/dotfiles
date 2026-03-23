{
  pkgs,
  inputs,
  self,
  username,
  host,
  vars,
  isServer,
  pkgs-stable,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit
        inputs
        self
        username
        host
        vars
        isServer
        pkgs-stable
        ;
    };
    users.${username} = {
      imports = [ ../../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };
  };
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = vars.gitUsername;
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
  nix.settings.allowed-users = [ "${username}" ];
}
