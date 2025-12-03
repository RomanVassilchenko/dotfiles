{
  pkgs,
  lib,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  workEnable = vars.workEnable or false;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";

  python = pkgs.python3.withPackages (ps: [ ps.pyqt6 ]);

  vpnTrayScript = pkgs.writeScriptBin "vpn-tray" ''
    #!${python}/bin/python3
    """
    VPN Tray Indicator for BerekeBank OpenConnect VPN
    Shows connection status and allows toggling VPN on/off
    """
    import subprocess
    import sys
    import os

    from PyQt6.QtWidgets import QApplication, QSystemTrayIcon, QMenu
    from PyQt6.QtGui import QIcon, QAction, QCursor
    from PyQt6.QtCore import QTimer

    SERVICE_NAME = "openconnect-berekebank"

    class VPNTray:
        def __init__(self):
            self.app = QApplication(sys.argv)
            self.app.setQuitOnLastWindowClosed(False)

            # Create tray icon
            self.tray = QSystemTrayIcon()
            self.update_icon()

            # Create menu
            self.menu = QMenu()

            self.status_action = QAction("Status: Checking...")
            self.status_action.setEnabled(False)
            self.menu.addAction(self.status_action)

            self.menu.addSeparator()

            self.toggle_action = QAction("Toggle VPN")
            self.toggle_action.triggered.connect(self.toggle_vpn)
            self.menu.addAction(self.toggle_action)

            self.restart_action = QAction("Restart VPN")
            self.restart_action.triggered.connect(self.restart_vpn)
            self.menu.addAction(self.restart_action)

            self.menu.addSeparator()

            quit_action = QAction("Quit")
            quit_action.triggered.connect(self.app.quit)
            self.menu.addAction(quit_action)

            self.tray.setContextMenu(self.menu)
            self.tray.activated.connect(self.on_tray_activated)
            self.tray.show()

            # Update status every 5 seconds
            self.timer = QTimer()
            self.timer.timeout.connect(self.update_status)
            self.timer.start(5000)

            # Initial status update
            self.update_status()

        def is_vpn_active(self):
            """Check if VPN service is active"""
            try:
                result = subprocess.run(
                    ["systemctl", "is-active", SERVICE_NAME],
                    capture_output=True,
                    text=True
                )
                return result.stdout.strip() == "active"
            except Exception:
                return False

        def get_vpn_ip(self):
            """Get VPN IP address from tun0 interface"""
            try:
                result = subprocess.run(
                    ["ip", "-4", "addr", "show", "tun0"],
                    capture_output=True,
                    text=True
                )
                for line in result.stdout.split("\n"):
                    if "inet " in line:
                        return line.split()[1].split("/")[0]
            except Exception:
                pass
            return None

        def update_icon(self):
            """Update tray icon based on VPN status"""
            active = self.is_vpn_active()
            if active:
                # Connected - use LAN with shield symbolic icon
                icon = QIcon.fromTheme("nm-device-wired-secure-symbolic")
                if icon.isNull():
                    icon = QIcon.fromTheme("network-wired-symbolic")
                self.tray.setIcon(icon)
                self.tray.setToolTip("BerekeBank VPN: Connected")
            else:
                # Disconnected - use symbolic no-connection icon
                icon = QIcon.fromTheme("nm-no-connection-symbolic")
                if icon.isNull():
                    icon = QIcon.fromTheme("network-offline-symbolic")
                self.tray.setIcon(icon)
                self.tray.setToolTip("BerekeBank VPN: Disconnected")

        def update_status(self):
            """Update status display"""
            self.update_icon()
            if self.is_vpn_active():
                ip = self.get_vpn_ip()
                if ip:
                    self.status_action.setText(f"Connected: {ip}")
                else:
                    self.status_action.setText("Connected")
                self.toggle_action.setText("Disconnect VPN")
            else:
                self.status_action.setText("Disconnected")
                self.toggle_action.setText("Connect VPN")

        def toggle_vpn(self):
            """Toggle VPN connection"""
            if self.is_vpn_active():
                subprocess.run(["sudo", "systemctl", "stop", SERVICE_NAME])
            else:
                subprocess.run(["sudo", "systemctl", "start", SERVICE_NAME])
            # Update status after a short delay
            QTimer.singleShot(2000, self.update_status)

        def restart_vpn(self):
            """Restart VPN connection"""
            subprocess.run(["sudo", "systemctl", "restart", SERVICE_NAME])
            QTimer.singleShot(2000, self.update_status)

        def on_tray_activated(self, reason):
            """Handle tray icon left click"""
            if reason == QSystemTrayIcon.ActivationReason.Trigger:
                self.menu.popup(QCursor.pos())

        def run(self):
            return self.app.exec()

    if __name__ == "__main__":
        tray = VPNTray()
        sys.exit(tray.run())
  '';

  vpnTrayDesktop = pkgs.makeDesktopItem {
    name = "vpn-tray";
    desktopName = "VPN Tray Indicator";
    exec = "${vpnTrayScript}/bin/vpn-tray";
    icon = "network-vpn";
    categories = [ "Network" "System" ];
    comment = "BerekeBank VPN status indicator";
  };
in
# VPN tray is a GUI app, only enable on desktop/laptop with workEnable
lib.mkIf (workEnable && !isServer) {
  home.packages = [
    vpnTrayScript
    vpnTrayDesktop
  ];

  # Autostart the VPN tray indicator
  xdg.configFile."autostart/vpn-tray.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=VPN Tray Indicator
    Comment=BerekeBank VPN status indicator
    Exec=${vpnTrayScript}/bin/vpn-tray
    Icon=network-vpn
    Terminal=false
    Categories=Network;System;
    X-KDE-autostart-phase=2
    NoDisplay=true
  '';
}
