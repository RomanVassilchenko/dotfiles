{
  pkgs,
  inputs,
  username,
  host,
  profile,
  vars,
  isServer,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    # Use hm-bak extension and clean old backups automatically
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        profile
        vars
        isServer
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
      "docker" # access to docker as non-root
      "libvirtd" # Virt manager/QEMU access
      "lp"
      "networkmanager"
      "scanner"
      "vboxusers" # Virtual Box
      "video" # access to webcam/video devices (required for WinApps webcam passthrough)
      "wheel" # subdo access
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    # SSH authorized keys for remote access
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInNKbTTbxK433xEXs5A3az+j7z9bBxdgPQn6BhiOgnq roman.vassilchenko.work@gmail.com"
    ];
  };
  nix.settings.allowed-users = [ "${username}" ];
}
