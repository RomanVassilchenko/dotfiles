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
  postman = vars.postman or defaultApp;
  prismlauncher = vars.prismlauncher or defaultApp;
  solaar = vars.solaar or defaultApp;
  telegram = vars.telegram or defaultApp;
  thunderbird = vars.thunderbird or defaultApp;
  zapzap = vars.zapzap or defaultApp;
  zoom = vars.zoom or defaultApp;
in
{
  _module.args = {
    # Pass app configs to modules
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

  imports = [
    # Configuration (always loaded)
    ./config/git.nix
    ./config/git-secrets-generator.nix
    ./config/ssh.nix
    ./config/ssh-secrets-generator.nix
    ./config/xdg.nix

    # Shell (always loaded)
    ./shell/zsh

    # Scripts (always loaded)
    ./scripts

    # CLI tools (always loaded)
    ./cli-tools/bat.nix
    ./cli-tools/btop.nix
    ./cli-tools/eza.nix
    ./cli-tools/fzf.nix
    ./cli-tools/lazygit.nix
    ./cli-tools/tealdeer.nix
    ./cli-tools/zoxide.nix
    ./cli-tools/direnv.nix
    ./cli-tools/atuin.nix
    ./cli-tools/nix-index.nix
    ./cli-tools/doc-tools.nix

    # Editors - nvf is TUI-based (always loaded)
    ./editors/nvf.nix
  ]
  ++ lib.optionals (!isServer) [
    # Stylix home-manager target overrides (only on systems with Stylix)
    ./config/stylix.nix

    # GUI Editors (laptop/desktop only)
    ./editors/vscode.nix

    # Fastfetch (laptop/desktop only - uses kitty image protocol)
    ./fastfetch

    # GUI Apps (laptop/desktop only, always loaded)
    ./apps/camunda-modeler.nix
    ./apps/obs-studio.nix
    ./apps/virtmanager.nix

    # Desktop (laptop/desktop only)
    ./desktop/kde

    # Terminal (laptop/desktop only - GUI terminal emulator)
    ./terminal/ghostty.nix
  ]
  # Configurable apps (conditional on enable)
  ++ lib.optionals (!isServer && bitwarden.enable) [ ./apps/bitwarden.nix ]
  ++ lib.optionals (!isServer && brave.enable) [ ./apps/brave.nix ]
  ++ lib.optionals (!isServer && dbeaver.enable) [ ./apps/dbeaver.nix ]
  ++ lib.optionals (!isServer && discord.enable) [ ./apps/discord.nix ]
  ++ lib.optionals (!isServer && gimp.enable) [ ./apps/gimp.nix ]
  ++ lib.optionals (!isServer && google-chrome.enable) [ ./apps/google-chrome.nix ]
  ++ lib.optionals (!isServer && inkscape.enable) [ ./apps/inkscape.nix ]
  ++ lib.optionals (!isServer && joplin.enable) [ ./apps/joplin.nix ]
  ++ lib.optionals (!isServer && krita.enable) [ ./apps/krita.nix ]
  ++ lib.optionals (!isServer && libreoffice.enable) [ ./apps/libreoffice.nix ]
  ++ lib.optionals (!isServer && osu-lazer.enable) [ ./apps/osu-lazer.nix ]
  ++ lib.optionals (!isServer && postman.enable) [ ./apps/postman.nix ]
  ++ lib.optionals (!isServer && prismlauncher.enable) [ ./apps/prismlauncher.nix ]
  ++ lib.optionals (!isServer && solaar.enable) [ ./apps/solaar.nix ]
  ++ lib.optionals (!isServer && telegram.enable) [ ./apps/telegram.nix ]
  ++ lib.optionals (!isServer && thunderbird.enable) [ ./apps/thunderbird.nix ]
  ++ lib.optionals (!isServer && zapzap.enable) [ ./apps/zapzap.nix ]
  ++ lib.optionals (!isServer && zoom.enable) [ ./apps/zoom.nix ];

  systemd.user.startServices = "sd-switch";
}
