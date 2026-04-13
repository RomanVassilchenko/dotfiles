{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages =
    (with pkgs-stable; [
      bitwarden-cli # Bitwarden CLI.
      rbw # Caching Bitwarden CLI.
      delta
      fd
      git
      git-absorb
      git-branchless
      jujutsu # Git, the full tooling.
      jq
      just
      ripgrep
      shfmt
      unrar
      unzip
      xdg-ninja
      zip
    ])
    ++ [
      pkgs.kitty.terminfo
      pkgs.nixfmt
    ];
}
