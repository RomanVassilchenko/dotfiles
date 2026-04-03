{
  config,
  lib,
  ...
}:
let
  cfg = config.features.development;
in
{
  options.features.development.enable = lib.mkEnableOption "development bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.development.enable = true;
  };
}
