{ ... }:
{
  imports = [
    # Configuration
    ./config/git.nix
    ./config/git-secrets-generator.nix
    ./config/ssh.nix
    ./config/ssh-secrets-generator.nix
    ./config/xdg.nix

    # Shell
    ./shell/zsh

    # Scripts
    ./scripts

    # CLI tools
    ./cli-tools/bat.nix
    ./cli-tools/btop.nix
    ./cli-tools/eza.nix
    ./cli-tools/fzf.nix
    ./cli-tools/lazygit.nix
    ./cli-tools/tealdeer.nix
    ./cli-tools/zoxide.nix

    # Editors
    ./editors/nvf.nix
    ./editors/vscode.nix
    ./editors/zed.nix

    # Fastfetch
    ./fastfetch

    # Apps
    ./apps/obs-studio.nix
    ./apps/virtmanager.nix

    # Desktop
    ./desktop/kde

    # Terminal
    ./terminal/ghostty.nix
  ];

  systemd.user.startServices = "sd-switch";
}
