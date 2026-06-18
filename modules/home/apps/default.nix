{
  dotfiles,
  lib,
  ...
}:
let
  moduleImports = import ../../../lib/module-imports.nix { inherit lib; };
in
{
  _module.args = {
    appConfig = {
      bitwarden.autostart = dotfiles.features.apps.bitwarden.autostart;
      discord.autostart = dotfiles.features.apps.discord.autostart;
      obsStudio.autostart = dotfiles.features.apps.obsStudio.autostart;
      "outlook-rdp".autostart = dotfiles.features.apps.outlookRdp.autostart;
      telegram.autostart = dotfiles.features.apps.telegram.autostart;
      zapzap.autostart = dotfiles.features.apps.zapzap.autostart;
    };
  };

  imports = moduleImports.filesIn ./.;
}
