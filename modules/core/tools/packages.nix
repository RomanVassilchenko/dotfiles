# Core programs and settings
{
  lib,
  isServer,
  ...
}:
{
  programs = {
    # Neovim - all systems
    neovim = {
      enable = true;
      defaultEditor = false;
    };

    # FUSE - all systems
    fuse.userAllowOther = true;

    # Network diagnostics - all systems
    mtr.enable = true;

    # GPG agent - all systems
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # nix-index provides "command-not-found" functionality - all systems
    nix-index.enable = true;
    command-not-found.enable = false; # nix-index handles this instead

    # Desktop-only programs
    dconf.enable = !isServer; # GNOME/GTK settings
    adb.enable = !isServer; # Android Debug Bridge

    # AppImage support - desktop only
    appimage = lib.mkIf (!isServer) {
      enable = true;
      binfmt = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
