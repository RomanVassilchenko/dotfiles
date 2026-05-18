{
  config,
  lib,
  pkgs,
  ...
}:
let
  catppuccinThunderbirdMochaMauve = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/thunderbird/main/themes/mocha/mocha-mauve.xpi";
    sha256 = "0h4zwi76189gwibajxzinzigdvjag04cmsqpqzddc8f1xh82p9q2";
  };
in
{
  environment.systemPackages =
    with pkgs;
    lib.optionals config.dotfiles.features.apps.discord.enable [ vesktop ]
    ++ lib.optionals config.dotfiles.features.apps.telegram.enable [ telegram-desktop ]
    ++ lib.optionals config.dotfiles.features.apps.zapzap.enable [ zapzap ];

  programs.thunderbird = lib.mkIf config.dotfiles.features.apps.thunderbird.enable {
    enable = true;
    policies = {
      ExtensionSettings = {
        "{47f5c9df-1d03-5424-ae9e-0613b69a9d2f}" = {
          installation_mode = "force_installed";
          install_url = "file://${catppuccinThunderbirdMochaMauve}";
        };
      };
    };
  };
}
