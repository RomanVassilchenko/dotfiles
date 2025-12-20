{
  pkgs,
  username,
  profile,
  ...
}:
{
  imports = [
    ./vpn-manager-tray.nix # Unified VPN manager (Bereke, AQ, Ninkear)
    ./service-monitor.nix
  ];

  home.packages = [
    (import ./dot.nix {
      inherit pkgs profile;
      backupFiles = [
        ".config/mimeapps.list.backup"
        # GTK backup files (managed by home-manager)
        ".gtkrc-2.0.hm-bak"
        ".config/gtk-3.0/gtk.css.hm-bak"
        ".config/gtk-3.0/settings.ini.hm-bak"
        ".config/gtk-4.0/gtk.css.hm-bak"
        ".config/gtk-4.0/settings.ini.hm-bak"
      ];
    })
  ];
}
