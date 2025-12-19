{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  config = lib.mkIf isServer {
    # Weekly cleanup service (runs after successful update)
    systemd.services.weekly-cleanup = {
      description = "Weekly NixOS cleanup and restart";
      path = with pkgs; [
        nix
        coreutils
        systemd
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        #!/bin/bash
        set -euo pipefail

        SUCCESS_FLAG="/var/lib/weekly-update/success"
        LOG_FILE="/var/log/weekly-cleanup.log"

        exec > >(tee -a "$LOG_FILE") 2>&1
        echo "=========================================="
        echo "Weekly cleanup started at $(date)"
        echo "=========================================="

        # Only proceed if weekly update was successful
        if [ ! -f "$SUCCESS_FLAG" ]; then
          echo "Weekly update did not succeed. Skipping cleanup."
          exit 0
        fi

        echo "[1/4] Removing old NixOS generations (keeping last 3)..."
        # List all generations and remove all but last 3
        nix-env --delete-generations +3 -p /nix/var/nix/profiles/system || true

        echo "[2/4] Running garbage collection..."
        nix-collect-garbage --delete-older-than 7d

        echo "[3/4] Optimizing nix store..."
        nix-store --optimise

        # Clear the success flag
        rm -f "$SUCCESS_FLAG"

        echo "[4/4] Scheduling reboot..."
        echo "=========================================="
        echo "Weekly cleanup completed at $(date)"
        echo "System will reboot now."
        echo "=========================================="

        # Reboot the system
        systemctl reboot
      '';
    };

    # Timer for Sunday 18:00 UTC+5
    systemd.timers.weekly-cleanup = {
      description = "Weekly NixOS cleanup timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Sun 18:00:00"; # Local time (Asia/Almaty = UTC+5)
        Persistent = false; # Don't run if missed - only run on schedule
      };
    };
  };
}
