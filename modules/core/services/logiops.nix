{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";

  # Logiops configuration for MX Master 3S
  logidConfig = ''
    devices: ({
      name: "Wireless Mouse MX Master 3S";

      // SmartShift (scroll wheel mode switching)
      smartshift: {
        on: true;
        threshold: 15;
      };

      // High-resolution scrolling
      hiresscroll: {
        hires: true;
        invert: false;
        target: false;
      };

      // DPI settings
      dpi: 1600;

      buttons: (
        // Gesture button (thumb button) - CID 0xc3
        {
          cid: 0xc3;
          action: {
            type: "Gestures";
            gestures: (
              // Swipe left = Next desktop (1->2->3->4->5->6)
              {
                direction: "Left";
                mode: "OnRelease";
                action: {
                  type: "Keypress";
                  keys: ["KEY_LEFTMETA", "KEY_PAGEDOWN"];
                };
              },
              // Swipe right = Previous desktop (6->5->4->3->2->1)
              {
                direction: "Right";
                mode: "OnRelease";
                action: {
                  type: "Keypress";
                  keys: ["KEY_LEFTMETA", "KEY_PAGEUP"];
                };
              },
              // Swipe up = Overview/Present Windows
              {
                direction: "Up";
                mode: "OnRelease";
                action: {
                  type: "Keypress";
                  keys: ["KEY_LEFTMETA", "KEY_W"];
                };
              },
              // Swipe down = Show desktop
              {
                direction: "Down";
                mode: "OnRelease";
                action: {
                  type: "Keypress";
                  keys: ["KEY_LEFTMETA", "KEY_D"];
                };
              },
              // No gesture (just click) = Middle click
              {
                direction: "None";
                mode: "OnRelease";
                action: {
                  type: "Keypress";
                  keys: ["BTN_MIDDLE"];
                };
              }
            );
          };
        },
        // Back button (thumb forward)
        {
          cid: 0x53;
          action: {
            type: "Keypress";
            keys: ["KEY_BACK"];
          };
        },
        // Forward button (thumb back)
        {
          cid: 0x56;
          action: {
            type: "Keypress";
            keys: ["KEY_FORWARD"];
          };
        }
      );
    });
  '';
in
{
  config = lib.mkIf (!isServer) {
    # Install logiops
    environment.systemPackages = [ pkgs.logiops ];

    # Create configuration file
    environment.etc."logid.cfg".text = logidConfig;

    # Enable and start the logiops daemon
    systemd.services.logiops = {
      description = "Logitech Configuration Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid";
        Restart = "on-failure";
        RestartSec = 3;

        # Run as root (required for device access)
        User = "root";
      };
    };

    # udev rules for Logitech devices
    services.udev.extraRules = ''
      # Logitech USB Receiver
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", MODE="0666"
      # Logitech devices via Bluetooth
      KERNEL=="hidraw*", ATTRS{idVendor}=="046d", MODE="0666"
    '';
  };
}
