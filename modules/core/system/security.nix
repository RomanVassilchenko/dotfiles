{
  config,
  username,
  lib,
  pkgs,
  ...
}:
let
  sudoAskpass = pkgs.writeShellApplication {
    name = "dotfiles-sudo-askpass";
    runtimeInputs = [
      pkgs.libnotify
    ];
    text = ''
      if [ -z "''${KITTY_WINDOW_ID:-}" ] && [ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" ]; then
        notify-send \
          --app-name=sudo \
          --urgency=normal \
          "Sudo password required" \
          "A graphical password prompt opened because this command is not running in kitty." \
          >/dev/null 2>&1 || true
      fi

      exec ${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass "$@"
    '';
  };
in
{
  environment = lib.mkIf config.dotfiles.features.desktop.enable {
    etc."sudo.conf".text = ''
      Path askpass ${sudoAskpass}/bin/dotfiles-sudo-askpass
    '';

    sessionVariables.SUDO_ASKPASS = "${sudoAskpass}/bin/dotfiles-sudo-askpass";
    systemPackages = [ sudoAskpass ];
  };

  security = {
    rtkit.enable = true;
    forcePageTableIsolation = true;
    protectKernelImage = true;
    tpm2.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ( subject.isInGroup("users") && (
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
           action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          ))
          { return polkit.Result.YES; }
        })
      '';
    };
    pam.services.swaylock = {
      text = "auth include login ";
    };
    sudo = {
      enable = true;
      extraRules = [
        {
          users = [ username ];
          commands = [
            {
              command = "/run/current-system/sw/bin/pkill *";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ]
      ++ lib.optionals config.dotfiles.host.isServer [
        {
          users = [ username ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };

  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = "0";
  };
}
