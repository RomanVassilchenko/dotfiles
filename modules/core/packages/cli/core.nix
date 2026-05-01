{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages =
    (with pkgs-stable; [
      bitwarden-cli # Bitwarden CLI.
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
      yq
      zip
    ])
    ++ [
      pkgs.kitty.terminfo
      pkgs.nixfmt
    ];
}
