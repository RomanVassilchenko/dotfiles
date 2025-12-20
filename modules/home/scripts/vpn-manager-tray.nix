# Unified VPN Manager Tray
# Supports Bereke Bank (OpenConnect), AQ (Fortinet), and Ninkear (Tailscale)
{
  pkgs,
  lib,
  vars,
  isServer,
  ...
}:
let
  workEnable = vars.workEnable or false;
  python = pkgs.python3.withPackages (ps: [ ps.pyqt6 ]);

  vpnManagerScript = pkgs.writeScriptBin "vpn-manager-tray" ''
    #!${python}/bin/python3
    """
    Unified VPN Manager Tray
    Supports multiple VPN connections with easy switching
    """
    import subprocess
    import sys
    import json
    import time

    from PyQt6.QtWidgets import QApplication, QSystemTrayIcon, QMenu, QWidgetAction, QWidget, QVBoxLayout, QLabel
    from PyQt6.QtGui import QIcon, QAction, QCursor, QFont
    from PyQt6.QtCore import QTimer

    # VPN Configurations
    VPNS = {
        "bereke": {
            "name": "Bereke Bank",
            "type": "systemd",
            "service": "openconnect-berekebank",
            "interface": "tun0",
        },
        "aq": {
            "name": "AQ (Dahua)",
            "type": "systemd",
            "service": "openfortivpn-dahua",
            "interface": "ppp0",
        },
        "ninkear": {
            "name": "Ninkear P2P",
            "type": "tailscale",
            "login_server": "http://127.0.0.1:18085",
        },
    }

    class VPNManager:
        def __init__(self):
            self.app = QApplication(sys.argv)
            self.app.setQuitOnLastWindowClosed(False)

            # Create tray icon
            self.tray = QSystemTrayIcon()
            self.update_icon()

            # Create menu
            self.menu = QMenu()
            self.vpn_actions = {}
            self.status_labels = {}

            # Header
            header = QAction("VPN Manager")
            header.setEnabled(False)
            font = header.font()
            font.setBold(True)
            header.setFont(font)
            self.menu.addAction(header)
            self.menu.addSeparator()

            # Add VPN entries
            for vpn_id, vpn_config in VPNS.items():
                self._add_vpn_menu(vpn_id, vpn_config)

            self.menu.addSeparator()

            # Disconnect all
            disconnect_all = QAction("Disconnect All")
            disconnect_all.triggered.connect(self.disconnect_all)
            self.menu.addAction(disconnect_all)

            self.menu.addSeparator()

            # Quit
            quit_action = QAction("Quit")
            quit_action.triggered.connect(self.app.quit)
            self.menu.addAction(quit_action)

            self.tray.setContextMenu(self.menu)
            self.tray.activated.connect(self.on_tray_activated)
            self.tray.show()

            # Update status every 5 seconds
            self.timer = QTimer()
            self.timer.timeout.connect(self.update_all_status)
            self.timer.start(5000)

            # Initial status update
            self.update_all_status()

        def _add_vpn_menu(self, vpn_id, vpn_config):
            """Add a VPN entry to the menu"""
            # Status label
            status_action = QAction(f"{vpn_config['name']}: Checking...")
            status_action.setEnabled(False)
            self.menu.addAction(status_action)
            self.status_labels[vpn_id] = status_action

            # Toggle action
            toggle_action = QAction("Connect")
            toggle_action.triggered.connect(lambda checked, vid=vpn_id: self.toggle_vpn(vid))
            self.menu.addAction(toggle_action)
            self.vpn_actions[vpn_id] = toggle_action

            self.menu.addSeparator()

        def is_vpn_active(self, vpn_id):
            """Check if a VPN is active"""
            vpn = VPNS[vpn_id]

            if vpn["type"] == "systemd":
                try:
                    result = subprocess.run(
                        ["systemctl", "is-active", vpn["service"]],
                        capture_output=True,
                        text=True
                    )
                    return result.stdout.strip() == "active"
                except Exception:
                    return False

            elif vpn["type"] == "tailscale":
                try:
                    result = subprocess.run(
                        ["tailscale", "status", "--json"],
                        capture_output=True,
                        text=True,
                        timeout=5
                    )
                    if result.returncode == 0:
                        status = json.loads(result.stdout)
                        return status.get("BackendState") == "Running"
                except Exception:
                    pass
                return False

            return False

        def get_vpn_ip(self, vpn_id):
            """Get VPN IP address"""
            vpn = VPNS[vpn_id]

            if vpn["type"] == "systemd":
                interface = vpn.get("interface", "tun0")
                try:
                    result = subprocess.run(
                        ["ip", "-4", "addr", "show", interface],
                        capture_output=True,
                        text=True
                    )
                    for line in result.stdout.split("\n"):
                        if "inet " in line:
                            return line.split()[1].split("/")[0]
                except Exception:
                    pass

            elif vpn["type"] == "tailscale":
                try:
                    result = subprocess.run(
                        ["tailscale", "status", "--json"],
                        capture_output=True,
                        text=True,
                        timeout=5
                    )
                    if result.returncode == 0:
                        status = json.loads(result.stdout)
                        if status.get("Self"):
                            ips = status["Self"].get("TailscaleIPs", [])
                            if ips:
                                return ips[0]
                except Exception:
                    pass

            return None

        def get_active_vpn_count(self):
            """Count active VPNs"""
            return sum(1 for vpn_id in VPNS if self.is_vpn_active(vpn_id))

        def update_icon(self):
            """Update tray icon based on VPN status"""
            active_count = self.get_active_vpn_count()

            if active_count > 0:
                icon = QIcon.fromTheme("network-vpn-symbolic")
                if icon.isNull():
                    icon = QIcon.fromTheme("network-wired-symbolic")
                self.tray.setIcon(icon)
                self.tray.setToolTip(f"VPN Manager: {active_count} active")
            else:
                icon = QIcon.fromTheme("network-vpn-disconnected-symbolic")
                if icon.isNull():
                    icon = QIcon.fromTheme("network-offline-symbolic")
                self.tray.setIcon(icon)
                self.tray.setToolTip("VPN Manager: Disconnected")

        def update_all_status(self):
            """Update status for all VPNs"""
            self.update_icon()

            for vpn_id, vpn_config in VPNS.items():
                is_active = self.is_vpn_active(vpn_id)
                ip = self.get_vpn_ip(vpn_id) if is_active else None

                if is_active:
                    if ip:
                        self.status_labels[vpn_id].setText(f"{vpn_config['name']}: {ip}")
                    else:
                        self.status_labels[vpn_id].setText(f"{vpn_config['name']}: Connected")
                    self.vpn_actions[vpn_id].setText("Disconnect")
                else:
                    self.status_labels[vpn_id].setText(f"{vpn_config['name']}: Disconnected")
                    self.vpn_actions[vpn_id].setText("Connect")

        def toggle_vpn(self, vpn_id):
            """Toggle a VPN connection"""
            vpn = VPNS[vpn_id]
            is_active = self.is_vpn_active(vpn_id)

            if vpn["type"] == "systemd":
                if is_active:
                    subprocess.run(["sudo", "systemctl", "stop", vpn["service"]])
                else:
                    subprocess.run(["sudo", "systemctl", "start", vpn["service"]])

            elif vpn["type"] == "tailscale":
                if is_active:
                    subprocess.run(["sudo", "tailscale", "down"])
                    subprocess.run(["pkill", "-f", "cloudflared access tcp.*headscale"])
                else:
                    # Start cloudflared tunnel first
                    subprocess.Popen([
                        "cloudflared", "access", "tcp",
                        "--hostname", "headscale.romanv.dev",
                        "--url", "127.0.0.1:18085"
                    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    time.sleep(2)
                    subprocess.run([
                        "sudo", "tailscale", "up",
                        "--login-server", vpn["login_server"],
                        "--accept-routes"
                    ])

            QTimer.singleShot(2000, self.update_all_status)

        def disconnect_all(self):
            """Disconnect all active VPNs"""
            for vpn_id in VPNS:
                if self.is_vpn_active(vpn_id):
                    self.toggle_vpn(vpn_id)

        def on_tray_activated(self, reason):
            """Handle tray icon left click"""
            if reason == QSystemTrayIcon.ActivationReason.Trigger:
                self.menu.popup(QCursor.pos())

        def run(self):
            return self.app.exec()

    if __name__ == "__main__":
        manager = VPNManager()
        sys.exit(manager.run())
  '';

  vpnManagerDesktop = pkgs.makeDesktopItem {
    name = "vpn-manager-tray";
    desktopName = "VPN Manager";
    exec = "${vpnManagerScript}/bin/vpn-manager-tray";
    icon = "network-vpn";
    categories = [
      "Network"
      "System"
    ];
    comment = "Unified VPN Manager (Bereke, AQ, Ninkear)";
  };
in
# VPN manager is a GUI app, only enable on desktop/laptop
lib.mkIf (!isServer) {
  home.packages = [
    vpnManagerScript
    vpnManagerDesktop
  ];

  # Autostart the VPN manager
  xdg.configFile."autostart/vpn-manager-tray.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=VPN Manager
    Comment=Unified VPN Manager (Bereke, AQ, Ninkear)
    Exec=${vpnManagerScript}/bin/vpn-manager-tray
    Icon=network-vpn
    Terminal=false
    Categories=Network;System;
    X-KDE-autostart-phase=2
    NoDisplay=true
  '';
}
