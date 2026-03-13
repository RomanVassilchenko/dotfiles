{
  pkgs,
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
  environment.systemPackages =
    with pkgs;
    [
      # duf
      # dust # Intuitive disk usage (du alternative)
      # dysk
      # lazyjournal # Journald/Docker logs TUI
      # ncdu
      dotCli
      inxi
      lm_sensors
      pciutils
      sbctl
      trash-cli
      usbutils
    ]
    ++ lib.optionals (!isServer) [
      v4l-utils
      mesa-demos
    ];
}
