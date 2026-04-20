{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    lib.optionals config.dotfiles.features.apps.discord.enable [ vesktop ]
    ++ lib.optionals config.dotfiles.features.apps.telegram.enable [ telegram-desktop ]
    ++ lib.optionals config.dotfiles.features.apps.zapzap.enable [ zapzap ];
}
