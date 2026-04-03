{
  config,
  lib,
  ...
}:
let
  cfg = config.features.productivity;
in
{
  options.features.productivity.enable = lib.mkEnableOption "productivity bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.productivity.enable = true;
    dotfiles.features.apps.bitwarden.enable = lib.mkDefault true;
  };
}
