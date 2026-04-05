{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.desktop.enable {
  environment.systemPackages = with pkgs; [
    (brave.override {
      commandLineArgs = "--disable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder";
    })
    google-chrome
  ];
}
