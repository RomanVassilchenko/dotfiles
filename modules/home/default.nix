{ lib, ... }:
let
  moduleImports = import ../../lib/module-imports.nix { inherit lib; };
in
{
  imports = [
    ./apps/default.nix
    ./desktop/kde/default.nix
    ./fastfetch/default.nix
  ]
  ++ moduleImports.filesInDirs [
    ./cli-tools
    ./config
    ./editors
    ./scripts
    ./shell/zsh
    ./terminal
  ];

  systemd.user.startServices = "sd-switch";
}
