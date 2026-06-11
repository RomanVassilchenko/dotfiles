{ dotfiles, lib, ... }:
{
  imports = [
    ./apps/default.nix
    ./cli-tools/atuin.nix
    ./cli-tools/bat.nix
    ./cli-tools/bitwarden.nix
    ./cli-tools/bottom.nix
    ./cli-tools/carapace.nix
    ./cli-tools/codex.nix
    ./cli-tools/direnv.nix
    ./cli-tools/gh.nix
    ./cli-tools/btop.nix
    ./cli-tools/eza.nix
    ./cli-tools/fzf.nix
    ./cli-tools/git-ai-commit.nix
    ./cli-tools/glow.nix
    ./cli-tools/lazygit.nix
    ./cli-tools/nix-index.nix
    ./cli-tools/procs.nix
    ./cli-tools/starship.nix
    ./cli-tools/yazi.nix
    ./cli-tools/zoxide.nix
    ./config/files.nix
    ./config/git-hooks.nix
    ./config/git.nix
    ./config/helium.nix
    ./config/ssh.nix
    ./config/xdg.nix
    ./desktop/kde/config.nix
    ./desktop/kde/displays.nix
    ./desktop/kde/panels.nix
    ./desktop/kde/places.nix
    ./desktop/kde/plasma-manager.nix
    ./desktop/kde/theme.nix
    ./desktop/kde/wallpaper.nix
    ./desktop/kde/widgets.nix
    ./editors/micro.nix
    ./editors/vscode.nix
    ./editors/zed.nix
    ./fastfetch/default.nix
    ./scripts/service-monitor.nix
    ./shell/zsh/aliases.nix
    ./shell/zsh/base.nix
    ./shell/zsh/fzf-tab.nix
    ./shell/zsh/helpers-and-completions.nix
    ./shell/zsh/keybindings-and-widgets.nix
    ./shell/zsh/palette.nix
    ./shell/zsh/syntax-highlighting.nix
    ./terminal/kitty.nix
  ]
  ++ lib.optionals dotfiles.features.stylix.enable [
    ./config/stylix.nix
  ];

  systemd.user.startServices = "sd-switch";
}
