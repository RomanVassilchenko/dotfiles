{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = with pkgs; [
    ruff
    uv
  ];
}
