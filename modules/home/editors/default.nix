# Text editors - nvf for TUI, vscode for GUI
{
  lib,
  isServer,
  ...
}:
{
  imports =
    [
      # nvf - TUI editor (all systems)
      ./nvf.nix
    ]
    ++ lib.optionals (!isServer) [
      # VSCode - GUI editor (desktop only)
      ./vscode.nix
    ];
}
