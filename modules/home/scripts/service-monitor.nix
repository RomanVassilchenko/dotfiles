{
  dotfiles,
  pkgs,
  lib,
  ...
}:
let
  checkServicesScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    set -euo pipefail

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m'

    echo "Checking systemd services..."
    echo ""

    failed_system=$(systemctl --system --failed --no-legend 2>/dev/null | wc -l)
    failed_user=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)
    total_failed=$((failed_system + failed_user))

    if [ "$total_failed" -gt 0 ]; then
      echo -e "''${RED}Found $total_failed failed service(s)!''${NC}"
      echo ""

      if [ "$failed_system" -gt 0 ]; then
        echo -e "''${YELLOW}System services:''${NC}"
        systemctl --system --failed --no-pager
        echo ""
      fi

      if [ "$failed_user" -gt 0 ]; then
        echo -e "''${YELLOW}User services:''${NC}"
        systemctl --user --failed --no-pager
        echo ""
      fi

      ${lib.optionalString dotfiles.features.desktop.enable ''
        if command -v notify-send &> /dev/null; then
          notify-send -u critical "Systemd Services" "$total_failed service(s) failed"
        fi
      ''}
      exit 1
    else
      echo -e "''${GREEN}All services are running!''${NC}"
      exit 0
    fi
  '';

  serviceLogsScript = pkgs.writeShellScriptBin "service-logs" ''
    if [ -z "''${1:-}" ]; then
      echo "Usage: service-logs <service-name>"
      echo "Example: service-logs sshd"
      exit 1
    fi
    journalctl -u "$1" -f --no-hostname
  '';

  restartFailedScript = pkgs.writeShellScriptBin "restart-failed" ''
    set -euo pipefail

    echo "Restarting failed system services..."
    for service in $(systemctl --system --failed --no-legend | awk '{print $1}'); do
      echo "Restarting $service..."
      sudo systemctl restart "$service" || echo "Failed to restart $service"
    done

    echo "Restarting failed user services..."
    for service in $(systemctl --user --failed --no-legend | awk '{print $1}'); do
      echo "Restarting $service..."
      systemctl --user restart "$service" || echo "Failed to restart $service"
    done

    echo "Done!"
  '';
in
{
  home.packages = [
    checkServicesScript
    restartFailedScript
    serviceLogsScript
  ];
}
