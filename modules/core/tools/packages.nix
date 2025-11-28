{
  pkgs,
  pkgs-pinned,
  inputs,
  ...
}:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = false;
    };
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
