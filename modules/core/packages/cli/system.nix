{
  config,
  pkgs,
  pkgs-stable,
  lib,
  ...
}:
let
  dotCli = pkgs.writeShellApplication {
    name = "dot";
    runtimeInputs = with pkgs; [
      git
      gnugrep
      nix
    ];
    text = ''
      set -euo pipefail

      PROJECT_DIR=${lib.escapeShellArg config.dotfiles.paths.dotfiles}
      FLAKE_REF="$PROJECT_DIR#dot"

      if git -C "$PROJECT_DIR" submodule status private 2>/dev/null | grep -qv "^-"; then
        FLAKE_REF="$PROJECT_DIR?submodules=1#dot"
      fi

      exec env DOT_PROJECT_DIR="$PROJECT_DIR" nix run "$FLAKE_REF" -- "$@"
    '';
  };
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
    pkgs-stable.ncdu # Interactive disk usage
  ]
  ++ lib.optionals config.dotfiles.features.desktop.enable [
    pkgs.v4l-utils
    pkgs.mesa-demos
  ];
}
