{
  config,
  lib,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = with pkgs-stable; [
    # lazysql # Database TUI
    postgresql
    squawk
  ];
}
