{
  pkgs,
  username,
  profile,
  ...
}:
{
  home.packages = [
    (import ./dot.nix {
      inherit pkgs profile;
      backupFiles = [
        ".config/mimeapps.list.backup"
      ];
    })
  ];
}
