{
  config,
  lib,
  pkgs-stable,
  ...
}:
lib.mkIf config.dotfiles.features.productivity.enable {
  environment.systemPackages =
    with pkgs-stable;
    [
      insync
      libreoffice
      obsidian
    ]
    ++ lib.optionals config.dotfiles.features.apps.bitwarden.enable [ bitwarden-desktop ];
}
