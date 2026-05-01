{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages = with pkgs; [
    (brave.override {
      commandLineArgs = lib.concatStringsSep " " [
        "--ozone-platform-hint=auto"
        "--disable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder"
      ];
    })
    google-chrome
  ];
}
