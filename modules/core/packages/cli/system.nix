{
  pkgs,
  pkgs-stable,
  lib,
  isServer,
  ...
}:
let
  dotCli = pkgs.writeShellScriptBin "dot" ''
    exec /home/romanv/Documents/dotfiles/dot.sh "$@"
  '';
in
{
  environment.systemPackages = [
    dotCli
    pkgs.nix-output-monitor
    pkgs.nvd
    pkgs-stable.inxi
    pkgs-stable.lm_sensors
    pkgs-stable.pciutils
    pkgs-stable.sbctl
    pkgs-stable.trash-cli
    pkgs-stable.usbutils
    pkgs-stable.duf # Disk usage (df alternative)
    pkgs-stable.dust # Intuitive disk usage (du alternative)
    # pkgs-stable.dysk
    pkgs-stable.lazyjournal # Journald/Docker logs TUI
    # pkgs-stable.ncdu # Interactive disk usage
  ]
  ++ lib.optionals (!isServer) [
    pkgs.v4l-utils
    pkgs.mesa-demos
  ];
}
