# Desktop applications - organized by category
# Desktop only - all apps are conditionally loaded based on variables.nix settings
{
  lib,
  vars,
  isServer,
  ...
}:
let
  # App config defaults
  defaultApp = {
    enable = false;
    autostart = false;
  };

  # Get app configs with defaults
  bitwarden = vars.bitwarden or defaultApp;
  brave = vars.brave or defaultApp;
  dbeaver = vars.dbeaver or defaultApp;
  discord = vars.discord or defaultApp;
  gimp = vars.gimp or defaultApp;
  google-chrome = vars.google-chrome or defaultApp;
  inkscape = vars.inkscape or defaultApp;
  joplin = vars.joplin or defaultApp;
  krita = vars.krita or defaultApp;
  libreoffice = vars.libreoffice or defaultApp;
  osu-lazer = vars.osu-lazer or defaultApp;
  outlook-rdp = vars.outlook-rdp or defaultApp;
  postman = vars.postman or defaultApp;
  prismlauncher = vars.prismlauncher or defaultApp;
  solaar = vars.solaar or defaultApp;
  telegram = vars.telegram or defaultApp;
  thunderbird = vars.thunderbird or defaultApp;
  zapzap = vars.zapzap or defaultApp;
  zoom = vars.zoom or defaultApp;
in
{
  # Pass app configs to individual app modules
  _module.args = {
    appConfig = {
      inherit
        bitwarden
        brave
        dbeaver
        discord
        gimp
        google-chrome
        inkscape
        joplin
        krita
        libreoffice
        osu-lazer
        outlook-rdp
        postman
        prismlauncher
        solaar
        telegram
        thunderbird
        zapzap
        zoom
        ;
    };
  };

  imports = lib.optionals (!isServer) (
    [
      # Always-loaded apps (no toggle)
      ./camunda-modeler.nix
      ./obs-studio.nix
      ./virtmanager.nix
    ]
    # Browsers
    ++ lib.optionals brave.enable [ ./brave.nix ]
    ++ lib.optionals google-chrome.enable [ ./google-chrome.nix ]

    # Communication
    ++ lib.optionals discord.enable [ ./discord.nix ]
    ++ lib.optionals telegram.enable [ ./telegram.nix ]
    ++ lib.optionals thunderbird.enable [ ./thunderbird.nix ]
    ++ lib.optionals zapzap.enable [ ./zapzap.nix ]
    ++ lib.optionals zoom.enable [ ./zoom.nix ]

    # Creative
    ++ lib.optionals gimp.enable [ ./gimp.nix ]
    ++ lib.optionals inkscape.enable [ ./inkscape.nix ]
    ++ lib.optionals krita.enable [ ./krita.nix ]

    # Productivity
    ++ lib.optionals bitwarden.enable [ ./bitwarden.nix ]
    ++ lib.optionals joplin.enable [ ./joplin.nix ]
    ++ lib.optionals libreoffice.enable [ ./libreoffice.nix ]

    # Development
    ++ lib.optionals dbeaver.enable [ ./dbeaver.nix ]
    ++ lib.optionals postman.enable [ ./postman.nix ]
    ++ lib.optionals outlook-rdp.enable [ ./outlook-rdp.nix ]

    # Gaming
    ++ lib.optionals osu-lazer.enable [ ./osu-lazer.nix ]
    ++ lib.optionals prismlauncher.enable [ ./prismlauncher.nix ]

    # Hardware
    ++ lib.optionals solaar.enable [ ./solaar.nix ]
  );
}
