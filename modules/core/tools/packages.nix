{
  lib,
  isServer,
  ...
}:
{
  programs = {
    fuse.userAllowOther = true;

    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    nix-index.enable = true;
    command-not-found.enable = false;

    dconf.enable = !isServer;

    appimage = lib.mkIf (!isServer) {
      enable = true;
      binfmt = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
