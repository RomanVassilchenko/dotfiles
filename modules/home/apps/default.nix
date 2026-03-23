{
  lib,
  vars,
  ...
}:
let
  deviceType = vars.deviceType or "laptop";

  bitwarden = vars.bitwarden or { };
  discord = vars.discord or { };
  solaar = vars.solaar or { };
  telegram = vars.telegram or { };
  zapzap = vars.zapzap or { };
in
{
  _module.args = {
    appConfig = {
      inherit
        bitwarden
        discord
        solaar
        telegram
        zapzap
        ;
    };
  };

  imports = lib.optionals (deviceType != "server") [
    ./bitwarden.nix
    ./camunda-modeler.nix
    ./discord.nix
    ./obs-studio.nix
    ./solaar.nix
    ./telegram.nix
    ./virtmanager.nix
    ./zapzap.nix
  ];
}
