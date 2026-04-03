{
  config,
  lib,
  ...
}:
let
  cfg = config.features.stylix;
in
{
  options.features.stylix.enable = lib.mkEnableOption "Stylix theming";

  config = lib.mkIf cfg.enable {
    dotfiles.features.stylix.enable = true;
  };
}
