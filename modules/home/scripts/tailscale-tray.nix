# Tailscale/Ninkear P2P Tray Indicator
# Shows connection status and allows toggling Tailscale on/off
{
  pkgs,
  lib,
  isServer,
  ...
}:
let
  python = pkgs.python3.withPackages (ps: [ ps.pyqt6 ]);

  tailscaleTrayScript = pkgs.writeScriptBin "tailscale-tray" ''
    #!${python}/bin/python3
    """
    Tailscale Tray Indicator for Ninkear P2P Network
    Shows connection status and allows toggling Tailscale on/off
    """
    import subprocess
    import sys
    import json

    from PyQt6.QtWidgets import QApplication, QSystemTrayIcon, QMenu
    from PyQt6.QtGui import QIcon, QAction, QCursor
    from PyQt6.QtCore import QTimer

    class TailscaleTray:
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

            self.ip_action = QAction("IP: --")
            self.ip_action.setEnabled(False)
            self.menu.addAction(self.ip_action)

            self.menu.addSeparator()

            self.toggle_action = QAction("Connect")
            self.toggle_action.triggered.connect(self.toggle_tailscale)
            self.menu.addAction(self.toggle_action)

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

        def get_tailscale_status(self):
            """Get Tailscale status as dict"""
            try:
                result = subprocess.run(
                    ["tailscale", "status", "--json"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if result.returncode == 0:
                    return json.loads(result.stdout)
            except Exception:
                pass
            return None

        def is_connected(self):
            """Check if Tailscale is connected"""
            status = self.get_tailscale_status()
            if status:
                backend_state = status.get("BackendState", "")
                return backend_state == "Running"
            return False

        def get_tailscale_ip(self):
            """Get Tailscale IP address"""
            status = self.get_tailscale_status()
            if status and status.get("Self"):
                ips = status["Self"].get("TailscaleIPs", [])
                if ips:
                    return ips[0]  # Return first IP (usually IPv4)
            return None

        def update_icon(self):
            """Update tray icon based on Tailscale status"""
            connected = self.is_connected()
            if connected:
                icon = QIcon.fromTheme("network-vpn-symbolic")
                if icon.isNull():
                    icon = QIcon.fromTheme("network-wired-symbolic")
                self.tray.setIcon(icon)
                self.tray.setToolTip("Ninkear P2P: Connected")
            else:
                icon = QIcon.fromTheme("network-vpn-disconnected-symbolic")
                if icon.isNull():
                    icon = QIcon.fromTheme("network-offline-symbolic")
                self.tray.setIcon(icon)
                self.tray.setToolTip("Ninkear P2P: Disconnected")

        def update_status(self):
            """Update status display"""
            self.update_icon()
            if self.is_connected():
                ip = self.get_tailscale_ip()
                self.status_action.setText("Connected")
                if ip:
                    self.ip_action.setText(f"IP: {ip}")
                else:
                    self.ip_action.setText("IP: --")
                self.toggle_action.setText("Disconnect")
            else:
                self.status_action.setText("Disconnected")
                self.ip_action.setText("IP: --")
                self.toggle_action.setText("Connect")

        def toggle_tailscale(self):
            """Toggle Tailscale connection"""
            if self.is_connected():
                subprocess.run(["sudo", "tailscale", "down"])
                # Kill cloudflared tunnel
                subprocess.run(["pkill", "-f", "cloudflared access tcp.*headscale"])
            else:
                # Start cloudflared TCP tunnel in background
                subprocess.Popen([
                    "cloudflared", "access", "tcp",
                    "--hostname", "headscale.romanv.dev",
                    "--url", "127.0.0.1:18085"
                ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                # Wait for tunnel to start
                import time
                time.sleep(2)
                # Connect via local tunnel
                subprocess.run([
                    "sudo", "tailscale", "up",
                    "--login-server=http://127.0.0.1:18085",
                    "--accept-routes"
                ])
            # Update status after a short delay
            QTimer.singleShot(2000, self.update_status)

        def on_tray_activated(self, reason):
            """Handle tray icon left click"""
            if reason == QSystemTrayIcon.ActivationReason.Trigger:
                self.menu.popup(QCursor.pos())

        def run(self):
            return self.app.exec()

    if __name__ == "__main__":
        tray = TailscaleTray()
        sys.exit(tray.run())
  '';

  tailscaleTrayDesktop = pkgs.makeDesktopItem {
    name = "tailscale-tray";
    desktopName = "Ninkear P2P Tray";
    exec = "${tailscaleTrayScript}/bin/tailscale-tray";
    icon = "network-vpn";
    categories = [
      "Network"
      "System"
    ];
    comment = "Ninkear P2P (Tailscale) status indicator";
  };
in
# Tailscale tray is a GUI app, only enable on desktop/laptop
lib.mkIf (!isServer) {
  home.packages = [
    tailscaleTrayScript
    tailscaleTrayDesktop
  ];

  # Autostart the Tailscale tray indicator
  xdg.configFile."autostart/tailscale-tray.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Ninkear P2P Tray
    Comment=Ninkear P2P (Tailscale) status indicator
    Exec=${tailscaleTrayScript}/bin/tailscale-tray
    Icon=network-vpn
    Terminal=false
    Categories=Network;System;
    X-KDE-autostart-phase=2
    NoDisplay=true
  '';
}
