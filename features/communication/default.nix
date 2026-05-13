{
  config,
  lib,
  ...
}:
let
  cfg = config.features.communication;
in
{
  options.features.communication.enable = lib.mkEnableOption "communication app bundle";

  config = lib.mkIf cfg.enable {
    dotfiles.features.apps = {
      discord.enable = lib.mkDefault true;
      telegram.enable = lib.mkDefault true;
      thunderbird.enable = lib.mkDefault true;
      zapzap.enable = lib.mkDefault true;
    };
  };
}
