# CLI tools - available on all systems via home-manager
{ ... }:
{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./eza.nix
    ./fzf.nix
    ./git-ai-commit.nix
    ./glow.nix
    ./lazygit.nix
    ./nix-index.nix
    ./zoxide.nix
  ];
}
