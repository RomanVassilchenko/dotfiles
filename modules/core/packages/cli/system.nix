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
    # duf # Disk usage (df alternative)
    # dust # Intuitive disk usage (du alternative)
    # dysk
    # lazyjournal # Journald/Docker logs TUI
    # ncdu # Interactive disk usage
  ]
  ++ lib.optionals (!isServer) [
    pkgs.v4l-utils
    pkgs.mesa-demos
  ];
}
