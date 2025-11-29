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
    # nix-index provides "command-not-found" functionality
    nix-index.enable = true;
    command-not-found.enable = false; # nix-index handles this instead
    # AppImage support - allows direct execution without appimage-run
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
