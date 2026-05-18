{
  config,
  pkgs,
  inputs,
  host,
  pkgs-stable,
  ...
}:
let
  inherit (config) dotfiles;
  userName = dotfiles.user.name;
  homeManagerBackup = pkgs.writeShellApplication {
    name = "home-manager-backup";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -eu

      target_path="$1"
      backup_ext="''${HOME_MANAGER_BACKUP_EXT:-hm-bak}"
      backup_path="$target_path.$backup_ext"

      if [ ! -e "$target_path" ]; then
        exit 0
      fi

      if [ -e "$backup_path" ]; then
        index=1
        while [ -e "$backup_path.$index" ]; do
          index=$((index + 1))
        done
        backup_path="$backup_path.$index"
      fi

      mv "$target_path" "$backup_path"
    '';
  };
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupCommand = "${homeManagerBackup}/bin/home-manager-backup";
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
        inherit (dotfiles.user) homeDirectory;
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
    openssh.authorizedKeys.keys = dotfiles.user.authorizedKeys;
  };
  nix.settings.allowed-users = [ userName ];
}
