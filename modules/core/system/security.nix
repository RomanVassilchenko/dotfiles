{ username, ... }:
{
  security = {
    rtkit.enable = true;
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
      text = ''auth include login '';
    };
    sudo = {
      extraRules = [
        {
          users = [ username ];
          commands = [
            {
              command = "/run/current-system/sw/bin/openfortivpn";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/pkill";
              options = [ "NOPASSWD" ];
            }
            # VPN service control without password
            {
              command = "/run/current-system/sw/bin/systemctl start openfortivpn-dahua";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl stop openfortivpn-dahua";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl restart openfortivpn-dahua";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl start openconnect-berekebank";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl stop openconnect-berekebank";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl restart openconnect-berekebank";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
