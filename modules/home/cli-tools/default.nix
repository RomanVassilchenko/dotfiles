# CLI tools - available on all systems via home-manager
{ ... }:
{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./doc-tools.nix
    ./eza.nix
    ./fzf.nix
    ./htop.nix
    ./lazygit.nix
    ./nix-index.nix
    ./tealdeer.nix
    ./zoxide.nix
  ];
}
