{
  config,
  lib,
  ...
}:
let
  cfg = config.features.printing;
in
{
  options.features.printing.enable = lib.mkEnableOption "printing feature bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.printing.enable = true;
  };
}
