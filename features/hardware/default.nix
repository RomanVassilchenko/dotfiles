{
  config,
  lib,
  ...
}:
let
  cfg = config.features.hardware;
in
{
  options.features.hardware.enable = lib.mkEnableOption "hardware utility app bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.apps.solaar.enable = lib.mkDefault true;
  };
}
