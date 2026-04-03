{
  dotfiles,
  lib,
  ...
}:
lib.mkIf dotfiles.features.apps.virtManager.enable {
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
