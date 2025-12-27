# Terminal emulators and multiplexers
{
  lib,
  isServer,
  ...
}:
{
  imports =
    [
      # Terminal multiplexers - all systems (useful for remote sessions)
      ./tmux.nix
      ./zellij.nix
    ]
    ++ lib.optionals (!isServer) [
      # GUI terminal emulator - desktop only
      ./ghostty.nix
    ];
}
