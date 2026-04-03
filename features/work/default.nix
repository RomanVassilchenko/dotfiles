{
  config,
  lib,
  ...
}:
let
  cfg = config.features.work;
in
{
  options.features.work.enable = lib.mkEnableOption "work feature bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.work.enable = true;
  };
}
