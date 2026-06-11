{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;

  mkAppOptions = name: {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Whether to enable ${name}. Null keeps the current defaults.";
    };

    autostart = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Whether to autostart ${name}. Null keeps the current defaults.";
    };
  };

  mkAppConfig =
    name: cfg:
    let
      path = [
        "dotfiles"
        "features"
        "apps"
        name
      ];
    in
    mkMerge [
      (mkIf (cfg.enable != null) (lib.setAttrByPath (path ++ [ "enable" ]) cfg.enable))
      (mkIf (cfg ? autostart && cfg.autostart != null) (
        lib.setAttrByPath (path ++ [ "autostart" ]) cfg.autostart
      ))
    ];

  mkAppConfigs = appConfigs: lib.mapAttrsToList mkAppConfig appConfigs;
in
{
  options.features.apps = {
    bitwarden = mkAppOptions "Bitwarden";
    discord = mkAppOptions "Discord/Vesktop";
    obsStudio = mkAppOptions "OBS Studio";
    telegram = mkAppOptions "Telegram";
    thunderbird = mkAppOptions "Thunderbird";
    zapzap = mkAppOptions "ZapZap";
  };

  config = mkMerge (mkAppConfigs {
    bitwarden = config.features.apps.bitwarden;
    discord = config.features.apps.discord;
    obsStudio = config.features.apps.obsStudio;
    telegram = config.features.apps.telegram;
    thunderbird = config.features.apps.thunderbird;
    zapzap = config.features.apps.zapzap;
  });
}
