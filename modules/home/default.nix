{
  lib,
  host,
  ...
}:
let
  vars = import ../../hosts/${host}/variables.nix;
  deviceType = vars.deviceType or "laptop";
  isServer = deviceType == "server";
in
{
  imports = [
    # Configuration (always loaded)
    ./config/git.nix
    ./config/git-secrets-generator.nix
    ./config/ssh.nix
    ./config/ssh-secrets-generator.nix
    ./config/xdg.nix

    # Shell (always loaded)
    ./shell/zsh

    # Scripts (always loaded)
    ./scripts

    # CLI tools (always loaded)
    ./cli-tools/bat.nix
    ./cli-tools/btop.nix
    ./cli-tools/eza.nix
    ./cli-tools/fzf.nix
    ./cli-tools/lazygit.nix
    ./cli-tools/tealdeer.nix
    ./cli-tools/zoxide.nix
    ./cli-tools/direnv.nix
    ./cli-tools/atuin.nix
    ./cli-tools/nix-index.nix

    # Editors - nvf is TUI-based (always loaded)
    ./editors/nvf.nix
  ]
  ++ lib.optionals (!isServer) [
    # GUI Editors (laptop/desktop only)
    ./editors/vscode.nix
    ./editors/zed.nix

    # Fastfetch (laptop/desktop only - uses kitty image protocol)
    ./fastfetch

    # GUI Apps (laptop/desktop only)
    ./apps/obs-studio.nix
    ./apps/virtmanager.nix

    # Desktop (laptop/desktop only)
    ./desktop/kde

    # Terminal (laptop/desktop only - GUI terminal emulator)
    ./terminal/ghostty.nix
  ];

  systemd.user.startServices = "sd-switch";
}
