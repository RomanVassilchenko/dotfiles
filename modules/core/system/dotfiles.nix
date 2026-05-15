{
  config,
  host,
  hostDefaults ? { },
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.dotfiles = {
    host = {
      name = mkOption {
        type = types.str;
        description = "Host name used for this NixOS configuration.";
      };

      profile = mkOption {
        type = types.enum [
          "workstation"
          "server"
        ];
        description = "High-level host profile, such as workstation or server.";
      };

      system = mkOption {
        type = types.str;
        description = "Target platform for this host.";
      };

      gpuProfile = mkOption {
        type = types.nullOr (
          types.enum [
            "intel"
            "amd"
          ]
        );
        default = null;
        description = "GPU driver profile selected for this host.";
      };

      deviceType = mkOption {
        type = types.enum [
          "laptop"
          "server"
        ];
        description = "Device class used by legacy desktop/server gating.";
      };

      isServer = mkOption {
        type = types.bool;
        description = "Whether this host should behave as a server-first system.";
      };
    };

    user = {
      name = mkOption {
        type = types.str;
        description = "Primary user account name.";
      };

      gitName = mkOption {
        type = types.str;
        description = "Display name used in Git configuration and user metadata.";
      };

      gitEmail = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Email address used for the default Git identity.";
      };

      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "SSH public keys allowed for the primary user account.";
      };

      homeDirectory = mkOption {
        type = types.str;
        description = "Primary user home directory.";
      };
    };

    paths = {
      dotfiles = mkOption {
        type = types.str;
        description = "Path to the dotfiles repository checkout.";
      };
    };

    locale = {
      timeZone = mkOption {
        type = types.str;
        description = "System time zone.";
      };

      defaultLocale = mkOption {
        type = types.str;
        description = "Primary system locale.";
      };

      keyboardLayout = mkOption {
        type = types.str;
        description = "XKB keyboard layout string for graphical sessions.";
      };

      consoleKeyMap = mkOption {
        type = types.str;
        description = "Console keymap used on TTYs.";
      };
    };

    features = {
      desktop = {
        enable = mkEnableOption "desktop base configuration";

        plasma.enable = mkEnableOption "KDE Plasma session support";
      };

      development.enable = mkEnableOption "development bundle";

      printing.enable = mkEnableOption "printing support";

      productivity.enable = mkEnableOption "productivity bundle";

      stylix.enable = mkEnableOption "Stylix theming";

      work.enable = mkEnableOption "work-specific tooling and integrations";

      apps = {
        bitwarden.enable = mkEnableOption "Bitwarden desktop app";

        bitwarden.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start Bitwarden automatically in graphical sessions.";
        };

        discord.enable = mkEnableOption "Discord/Vesktop desktop app";

        discord.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start Discord automatically in graphical sessions.";
        };

        obsStudio.enable = mkEnableOption "OBS Studio desktop app";

        obsStudio.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start OBS Studio automatically in graphical sessions.";
        };

        outlookRdp.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start the Outlook RDP launcher automatically in graphical sessions.";
        };

        solaar.enable = mkEnableOption "Solaar desktop app";

        solaar.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start Solaar automatically in graphical sessions.";
        };

        telegram.enable = mkEnableOption "Telegram desktop app";

        telegram.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start Telegram automatically in graphical sessions.";
        };

        thunderbird.enable = mkEnableOption "Thunderbird desktop app";

        thunderbird.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start Birdtray for Thunderbird automatically in graphical sessions.";
        };

        virtManager.enable = mkEnableOption "virt-manager desktop app";

        zapzap.enable = mkEnableOption "ZapZap desktop app";

        zapzap.autostart = mkOption {
          type = types.bool;
          default = false;
          description = "Start ZapZap automatically in graphical sessions.";
        };
      };
    };
  };

  config = {
    dotfiles = {
      host = {
        name = mkDefault host;
        profile = mkDefault (hostDefaults.host.profile or "workstation");
        system = mkDefault (hostDefaults.host.system or "x86_64-linux");
        gpuProfile = mkDefault (hostDefaults.host.gpuProfile or null);
        deviceType = mkDefault (
          hostDefaults.host.deviceType
            or (if config.dotfiles.host.profile == "server" then "server" else "laptop")
        );
        isServer = mkDefault (config.dotfiles.host.deviceType == "server");
      };

      user = {
        name = mkDefault (hostDefaults.user.name or "youruser");
        gitName = mkDefault (hostDefaults.user.gitName or "Your Name");
        gitEmail = mkDefault (hostDefaults.user.gitEmail or null);
        authorizedKeys = mkDefault (hostDefaults.user.authorizedKeys or [ ]);
        homeDirectory = mkDefault "/home/${config.dotfiles.user.name}";
      };

      paths = {
        dotfiles = mkDefault (
          hostDefaults.paths.dotfiles or "${config.dotfiles.user.homeDirectory}/dotfiles"
        );
      };

      locale = {
        timeZone = mkDefault (hostDefaults.locale.timeZone or "UTC");
        defaultLocale = mkDefault (hostDefaults.locale.defaultLocale or "en_US.UTF-8");
        keyboardLayout = mkDefault (hostDefaults.locale.keyboardLayout or "us");
        consoleKeyMap = mkDefault (hostDefaults.locale.consoleKeyMap or "us");
      };

      features = {
        desktop.enable = mkDefault (!config.dotfiles.host.isServer);
        desktop.plasma.enable = mkDefault false;
        stylix.enable = mkDefault config.dotfiles.features.desktop.enable;

        apps.obsStudio.enable = mkDefault config.dotfiles.features.desktop.enable;
        apps.virtManager.enable = mkDefault false;
      };
    };

    assertions = [
      {
        assertion = config.dotfiles.user.name != "";
        message = "dotfiles.user.name must not be empty.";
      }
      {
        assertion = config.dotfiles.user.gitName != "";
        message = "dotfiles.user.gitName must not be empty.";
      }
      {
        assertion = config.dotfiles.host.system != "";
        message = "dotfiles.host.system must not be empty.";
      }
      {
        assertion = config.dotfiles.locale.keyboardLayout != "";
        message = "dotfiles.locale.keyboardLayout must not be empty.";
      }
      {
        assertion = config.dotfiles.locale.consoleKeyMap != "";
        message = "dotfiles.locale.consoleKeyMap must not be empty.";
      }
    ];
  };
}
