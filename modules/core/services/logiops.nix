{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages = [ pkgs-stable.logiops ];

  environment.etc."logid.cfg".text = ''
    devices: ({
      name: "MX Master 3S";

      buttons: (
        {
          cid: 0xc3;  // Thumb gesture button
          action =
          {
            type: "Gestures";
            gestures: (
              // Gesture RIGHT → Previous desktop
              {
                direction: "Right";
                mode: "OnRelease";
                action =
                {
                  type: "Keypress";
                  keys: [ "KEY_LEFTMETA", "KEY_PAGEUP" ];
                };
              },
              // Gesture LEFT → Next desktop
              {
                direction: "Left";
                mode: "OnRelease";
                action =
                {
                  type: "Keypress";
                  keys: [ "KEY_LEFTMETA", "KEY_PAGEDOWN" ];
                };
              }
            );
          };
        }
      );
    });
  '';

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", RUN+="${pkgs.systemd}/bin/systemctl restart logiops.service"
  '';

  systemd.services.logiops = {
    description = "Logitech Configuration Daemon";
    wantedBy = [ "multi-user.target" ];
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs-stable.logiops}/bin/logid";
      Restart = "on-failure";
    };
  };
}
