{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  config = lib.mkIf isServer {
    # Weekly flake update service
    systemd.services.weekly-flake-update = {
      description = "Weekly NixOS flake update and rebuild";
      path = with pkgs; [
        git
        nix
        nixos-rebuild
        openssh
        coreutils
        bash
      ];
      environment = {
        HOME = "/root";
        NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        WorkingDirectory = "/home/romanv/backup/dotfiles";
        TimeoutStartSec = "2h"; # Allow up to 2 hours for builds
      };
      script = ''
        #!/bin/bash
        set -euo pipefail

        DOTFILES="/home/romanv/backup/dotfiles"
        LOG_FILE="/var/log/weekly-update.log"
        SUCCESS_FLAG="/var/lib/weekly-update/success"

        # Ensure directories exist
        mkdir -p /var/lib/weekly-update
        rm -f "$SUCCESS_FLAG"

        exec > >(tee -a "$LOG_FILE") 2>&1
        echo "=========================================="
        echo "Weekly update started at $(date)"
        echo "=========================================="

        cd "$DOTFILES"

        # Configure git safe directory (needed when running as root)
        git config --global --add safe.directory "$DOTFILES" || true

        # Ensure we have the latest from remote
        echo "[1/8] Fetching latest changes from remote..."
        git fetch origin main
        git reset --hard origin/main

        # Update flake inputs
        echo "[2/8] Updating flake inputs..."
        nix flake update

        # Check if flake.lock changed
        if git diff --quiet flake.lock; then
          echo "No flake updates available. Exiting."
          touch "$SUCCESS_FLAG"
          exit 0
        fi

        echo "[3/8] Committing flake.lock update..."
        git add flake.lock
        git commit -m "chore: update flake.lock"

        echo "[4/8] Building ninkear configuration..."
        nix build .#nixosConfigurations.ninkear.config.system.build.toplevel --no-link

        echo "[5/8] Building laptop-82sn configuration (for cache)..."
        nix build .#nixosConfigurations.laptop-82sn.config.system.build.toplevel --no-link || echo "Warning: laptop-82sn build failed, continuing..."

        echo "[6/8] Building probook-450 configuration (for cache)..."
        nix build .#nixosConfigurations.probook-450.config.system.build.toplevel --no-link || echo "Warning: probook-450 build failed, continuing..."

        echo "[7/8] Applying ninkear configuration..."
        nixos-rebuild switch --flake .#ninkear

        echo "[8/8] Pushing changes..."
        git push origin main

        # Mark as successful
        touch "$SUCCESS_FLAG"
        echo "=========================================="
        echo "Weekly update completed successfully at $(date)"
        echo "=========================================="
      '';
    };

    # Timer for Sunday 12:00 UTC+5 (which is 07:00 UTC)
    systemd.timers.weekly-flake-update = {
      description = "Weekly NixOS flake update timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Sun 12:00:00"; # Local time (Asia/Almaty = UTC+5)
        Persistent = true; # Run if missed (e.g., system was off)
        RandomizedDelaySec = "5min";
      };
    };
  };
}
