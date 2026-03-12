{ username, ... }:
{
  security = {
    rtkit.enable = true;
    forcePageTableIsolation = true;
    protectKernelImage = true;
    tpm2.enable = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = false;
    };
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
            {
              command = "/run/current-system/sw/bin/cat /run/agenix/headscale-preauth-key";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };

  systemd.coredump.extraConfig = ''
    Storage=none
    ProcessSizeMax=0
  '';
}
