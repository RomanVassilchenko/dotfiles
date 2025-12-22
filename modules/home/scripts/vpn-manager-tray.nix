# VPN Manager Plasma Applet
# Native KDE Plasma widget for managing VPN connections
# Supports Bereke Bank (OpenConnect), AQ (Fortinet), and Ninkear (Tailscale)
{
  pkgs,
  lib,
  isServer,
  ...
}:
let
  # Helper script for VPN operations (called by the plasmoid)
  vpnHelper = pkgs.writeShellScriptBin "vpn-manager-helper" ''
    #!/usr/bin/env bash
    set -euo pipefail

    ACTION="$1"
    VPN_ID="''${2:-}"

    # VPN configurations
    declare -A VPN_SERVICE=(
      ["bereke"]="openconnect-berekebank"
      ["aq"]="openfortivpn-dahua"
      ["ninkear"]="tailscale"
    )

    declare -A VPN_INTERFACE=(
      ["bereke"]="tun0"
      ["aq"]="ppp0"
      ["ninkear"]="tailscale0"
    )

    get_status() {
      local vpn="$1"
      if [[ "$vpn" == "ninkear" ]]; then
        if tailscale status --json 2>/dev/null | ${pkgs.jq}/bin/jq -e '.BackendState == "Running"' >/dev/null 2>&1; then
          echo "active"
        else
          echo "inactive"
        fi
      else
        systemctl is-active "''${VPN_SERVICE[$vpn]}" 2>/dev/null || echo "inactive"
      fi
    }

    get_ip() {
      local vpn="$1"
      if [[ "$vpn" == "ninkear" ]]; then
        tailscale status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.Self.TailscaleIPs[0] // empty' 2>/dev/null || true
      else
        ip -4 addr show "''${VPN_INTERFACE[$vpn]}" 2>/dev/null | grep -oP 'inet \K[\d.]+' || true
      fi
    }

    connect_vpn() {
      local vpn="$1"
      if [[ "$vpn" == "ninkear" ]]; then
        # Start cloudflared tunnel first
        ${pkgs.cloudflared}/bin/cloudflared access tcp \
          --hostname headscale.romanv.dev \
          --url 127.0.0.1:18085 &
        sleep 2
        sudo tailscale up --login-server http://127.0.0.1:18085 --accept-routes --accept-dns=false
      else
        sudo systemctl start "''${VPN_SERVICE[$vpn]}"
      fi
    }

    disconnect_vpn() {
      local vpn="$1"
      if [[ "$vpn" == "ninkear" ]]; then
        sudo tailscale down
        pkill -f "cloudflared access tcp.*headscale" || true
      else
        sudo systemctl stop "''${VPN_SERVICE[$vpn]}"
      fi
    }

    case "$ACTION" in
      status)
        # Output JSON status for all VPNs
        echo "{"
        echo "  \"bereke\": {"
        echo "    \"active\": $([ "$(get_status bereke)" = "active" ] && echo "true" || echo "false"),"
        echo "    \"ip\": \"$(get_ip bereke)\""
        echo "  },"
        echo "  \"aq\": {"
        echo "    \"active\": $([ "$(get_status aq)" = "active" ] && echo "true" || echo "false"),"
        echo "    \"ip\": \"$(get_ip aq)\""
        echo "  },"
        echo "  \"ninkear\": {"
        echo "    \"active\": $([ "$(get_status ninkear)" = "active" ] && echo "true" || echo "false"),"
        echo "    \"ip\": \"$(get_ip ninkear)\""
        echo "  }"
        echo "}"
        ;;
      connect)
        connect_vpn "$VPN_ID"
        ;;
      disconnect)
        disconnect_vpn "$VPN_ID"
        ;;
      toggle)
        if [[ "$(get_status "$VPN_ID")" == "active" ]]; then
          disconnect_vpn "$VPN_ID"
        else
          connect_vpn "$VPN_ID"
        fi
        ;;
      connect-all)
        for vpn in bereke aq ninkear; do
          if [[ "$(get_status "$vpn")" != "active" ]]; then
            connect_vpn "$vpn" &
          fi
        done
        wait
        ;;
      disconnect-all)
        for vpn in bereke aq ninkear; do
          if [[ "$(get_status "$vpn")" == "active" ]]; then
            disconnect_vpn "$vpn" &
          fi
        done
        wait
        ;;
      *)
        echo "Usage: $0 {status|connect|disconnect|toggle|connect-all|disconnect-all} [vpn_id]"
        exit 1
        ;;
    esac
  '';

  # Plasma applet package
  vpnPlasmoid = pkgs.stdenv.mkDerivation {
    pname = "plasma-applet-vpn-manager";
    version = "1.0.0";

    src = pkgs.writeTextDir "plasma-applet-vpn-manager" "";

    installPhase = ''
      mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.vpnmanager

      # metadata.json
      cat > $out/share/plasma/plasmoids/org.kde.plasma.vpnmanager/metadata.json << 'METADATA'
      {
        "KPlugin": {
          "Id": "org.kde.plasma.vpnmanager",
          "Name": "VPN Manager",
          "Description": "Manage VPN connections (Bereke, AQ, Ninkear)",
          "Icon": "network-vpn",
          "Authors": [{ "Name": "romanv" }],
          "Category": "System Information",
          "Version": "1.0.0"
        },
        "X-Plasma-API-Minimum-Version": "6.0",
        "KPackageStructure": "Plasma/Applet"
      }
      METADATA

      mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.vpnmanager/contents/ui

      # Main QML file
      cat > $out/share/plasma/plasmoids/org.kde.plasma.vpnmanager/contents/ui/main.qml << 'QML'
      import QtQuick
      import QtQuick.Layouts
      import org.kde.plasma.plasmoid
      import org.kde.plasma.plasma5support as Plasma5Support
      import org.kde.plasma.components as PlasmaComponents
      import org.kde.kirigami as Kirigami

      PlasmoidItem {
          id: root

          property var vpnStatus: ({
              "bereke": { "active": false, "ip": "" },
              "aq": { "active": false, "ip": "" },
              "ninkear": { "active": false, "ip": "" }
          })

          readonly property string helperPath: "${vpnHelper}/bin/vpn-manager-helper"

          // Colors for status dots
          readonly property color berekeColor: vpnStatus.bereke.active ? "#ef4444" : "#6b7280"
          readonly property color aqColor: vpnStatus.aq.active ? "#22c55e" : "#6b7280"
          readonly property color ninkearColor: vpnStatus.ninkear.active ? "#3b82f6" : "#6b7280"

          readonly property int activeCount: (vpnStatus.bereke.active ? 1 : 0) +
                                              (vpnStatus.aq.active ? 1 : 0) +
                                              (vpnStatus.ninkear.active ? 1 : 0)

          toolTipMainText: activeCount > 0 ? "VPN: " + activeCount + " connected" : "VPN: Disconnected"
          toolTipSubText: {
              var parts = [];
              if (vpnStatus.bereke.active) parts.push("Bereke: " + vpnStatus.bereke.ip);
              if (vpnStatus.aq.active) parts.push("AQ: " + vpnStatus.aq.ip);
              if (vpnStatus.ninkear.active) parts.push("Ninkear: " + vpnStatus.ninkear.ip);
              return parts.join("\n") || "Click to manage";
          }

          Plasmoid.icon: activeCount > 0 ? "network-vpn" : "network-vpn-disconnected"

          // DataSource for running commands
          Plasma5Support.DataSource {
              id: executable
              engine: "executable"
              connectedSources: []

              onNewData: function(source, data) {
                  var exitCode = data["exit code"];
                  var stdout = data["stdout"];

                  if (source === helperPath + " status") {
                      if (exitCode === 0 && stdout) {
                          try {
                              root.vpnStatus = JSON.parse(stdout);
                          } catch (e) {
                              console.log("Failed to parse VPN status:", e);
                          }
                      }
                  } else {
                      // Action completed, refresh status
                      updateStatus();
                  }

                  disconnectSource(source);
              }
          }

          function updateStatus() {
              executable.connectSource(helperPath + " status");
          }

          function toggleVpn(vpnId) {
              executable.connectSource(helperPath + " toggle " + vpnId);
          }

          function runHelper(action) {
              executable.connectSource(helperPath + " " + action);
          }

          // Compact representation (icon in panel/tray)
          compactRepresentation: Item {
              id: compactRoot

              Kirigami.Icon {
                  id: vpnIcon
                  anchors.fill: parent
                  anchors.bottomMargin: 4  // Leave space for status bars
                  source: root.activeCount > 0 ? "network-vpn-symbolic" : "network-vpn-disconnected-symbolic"
              }

              // Three status bars at bottom (Bereke=red, AQ=green, Ninkear=blue)
              Row {
                  anchors.bottom: parent.bottom
                  anchors.horizontalCenter: parent.horizontalCenter
                  anchors.bottomMargin: 0
                  spacing: 1

                  Rectangle {
                      width: 6; height: 3; radius: 1
                      color: root.vpnStatus.bereke.active ? "#ef4444" : "#4b5563"
                      opacity: root.vpnStatus.bereke.active ? 1.0 : 0.4
                  }
                  Rectangle {
                      width: 6; height: 3; radius: 1
                      color: root.vpnStatus.aq.active ? "#22c55e" : "#4b5563"
                      opacity: root.vpnStatus.aq.active ? 1.0 : 0.4
                  }
                  Rectangle {
                      width: 6; height: 3; radius: 1
                      color: root.vpnStatus.ninkear.active ? "#3b82f6" : "#4b5563"
                      opacity: root.vpnStatus.ninkear.active ? 1.0 : 0.4
                  }
              }

              MouseArea {
                  anchors.fill: parent
                  onClicked: root.expanded = !root.expanded
              }
          }

          // Full representation (popup menu)
          fullRepresentation: ColumnLayout {
              Layout.minimumWidth: Kirigami.Units.gridUnit * 16
              Layout.minimumHeight: Kirigami.Units.gridUnit * 14
              spacing: Kirigami.Units.smallSpacing

              // Header
              PlasmaComponents.Label {
                  Layout.fillWidth: true
                  text: "VPN Manager"
                  font.bold: true
                  horizontalAlignment: Text.AlignHCenter
              }

              Kirigami.Separator { Layout.fillWidth: true }

              // VPN entries
              Repeater {
                  model: [
                      { id: "bereke", name: "Bereke Bank", color: "#ef4444" },
                      { id: "aq", name: "AQ (Dahua)", color: "#22c55e" },
                      { id: "ninkear", name: "Ninkear P2P", color: "#3b82f6" }
                  ]

                  delegate: ColumnLayout {
                      Layout.fillWidth: true
                      spacing: Kirigami.Units.smallSpacing

                      RowLayout {
                          Layout.fillWidth: true

                          Rectangle {
                              width: 10; height: 10; radius: 5
                              color: root.vpnStatus[modelData.id].active ? modelData.color : "#6b7280"
                          }

                          PlasmaComponents.Label {
                              Layout.fillWidth: true
                              text: modelData.name + ": " +
                                    (root.vpnStatus[modelData.id].active ?
                                     (root.vpnStatus[modelData.id].ip || "Connected") :
                                     "Disconnected")
                          }
                      }

                      PlasmaComponents.Button {
                          Layout.fillWidth: true
                          text: root.vpnStatus[modelData.id].active ? "Disconnect" : "Connect"
                          onClicked: root.toggleVpn(modelData.id)
                      }

                      Kirigami.Separator { Layout.fillWidth: true }
                  }
              }

              // Connect All / Disconnect All
              RowLayout {
                  Layout.fillWidth: true
                  spacing: Kirigami.Units.smallSpacing

                  PlasmaComponents.Button {
                      Layout.fillWidth: true
                      text: "Connect All"
                      icon.name: "network-vpn"
                      onClicked: root.runHelper("connect-all")
                  }

                  PlasmaComponents.Button {
                      Layout.fillWidth: true
                      text: "Disconnect All"
                      icon.name: "network-vpn-disconnected"
                      onClicked: root.runHelper("disconnect-all")
                  }
              }

              Item { Layout.fillHeight: true }
          }

          // Status update timer
          Timer {
              id: statusTimer
              interval: 5000
              running: true
              repeat: true
              triggeredOnStart: true
              onTriggered: root.updateStatus()
          }

          Component.onCompleted: updateStatus()
      }
      QML
    '';
  };
in
lib.mkIf (!isServer) {
  home.packages = [
    vpnHelper
    vpnPlasmoid
  ];
}
