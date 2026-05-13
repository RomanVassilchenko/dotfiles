{
  dotfiles,
  ...
}:
{
  _module.args = {
    appConfig = {
      bitwarden.autostart = dotfiles.features.apps.bitwarden.autostart;
      discord.autostart = dotfiles.features.apps.discord.autostart;
      obsStudio.autostart = dotfiles.features.apps.obsStudio.autostart;
      "outlook-rdp".autostart = dotfiles.features.apps.outlookRdp.autostart;
      solaar.autostart = dotfiles.features.apps.solaar.autostart;
      telegram.autostart = dotfiles.features.apps.telegram.autostart;
      thunderbird.autostart = dotfiles.features.apps.thunderbird.autostart;
      zapzap.autostart = dotfiles.features.apps.zapzap.autostart;
    };
  };

  imports = [
    ./bitwarden.nix
    ./camunda-modeler.nix
    ./discord.nix
    ./obs-studio.nix
    ./solaar.nix
    ./telegram.nix
    ./thunderbird.nix
    ./virtmanager.nix
    ./zapzap.nix
  ];
}
