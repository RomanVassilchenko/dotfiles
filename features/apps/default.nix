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
    path: cfg:
    mkMerge [
      (mkIf (cfg.enable != null) (lib.setAttrByPath (path ++ [ "enable" ]) cfg.enable))
      (mkIf (cfg.autostart != null) (lib.setAttrByPath (path ++ [ "autostart" ]) cfg.autostart))
    ];
in
{
  options.features.apps = {
    bitwarden = mkAppOptions "Bitwarden";
    discord = mkAppOptions "Discord/Vesktop";
    obsStudio = mkAppOptions "OBS Studio";
    solaar = mkAppOptions "Solaar";
    telegram = mkAppOptions "Telegram";
    thunderbird.enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Whether to enable Thunderbird. Null keeps the current defaults.";
    };
    virtManager.enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Whether to enable virt-manager. Null keeps the current defaults.";
    };
    zapzap = mkAppOptions "ZapZap";
  };

  config = mkMerge [
    (mkAppConfig [ "dotfiles" "features" "apps" "bitwarden" ] config.features.apps.bitwarden)
    (mkAppConfig [ "dotfiles" "features" "apps" "discord" ] config.features.apps.discord)
    (mkAppConfig [ "dotfiles" "features" "apps" "obsStudio" ] config.features.apps.obsStudio)
    (mkAppConfig [ "dotfiles" "features" "apps" "solaar" ] config.features.apps.solaar)
    (mkAppConfig [ "dotfiles" "features" "apps" "telegram" ] config.features.apps.telegram)
    (mkIf (config.features.apps.thunderbird.enable != null) {
      dotfiles.features.apps.thunderbird.enable = config.features.apps.thunderbird.enable;
    })
    (mkIf (config.features.apps.virtManager.enable != null) {
      dotfiles.features.apps.virtManager.enable = config.features.apps.virtManager.enable;
    })
    (mkAppConfig [ "dotfiles" "features" "apps" "zapzap" ] config.features.apps.zapzap)
  ];
}
