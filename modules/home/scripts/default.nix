{
  pkgs,
  username,
  profile,
  ...
}:
{
  imports = [
    ./vpn-tray.nix
  ];

  home.packages = [
    (import ./dot.nix {
      inherit pkgs profile;
      backupFiles = [
        ".config/mimeapps.list.backup"
      ];
    })
  ];
}
