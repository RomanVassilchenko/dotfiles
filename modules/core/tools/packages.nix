{
  config,
  lib,
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

    dconf.enable = config.dotfiles.features.desktop.enable || config.dotfiles.features.stylix.enable;

    appimage = lib.mkIf config.dotfiles.features.desktop.enable {
      enable = true;
      binfmt = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
