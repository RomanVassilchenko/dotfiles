{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages =
    (with pkgs-stable; [
      delta
      fd
      git
      git-absorb
      git-branchless
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
      pkgs.nixfmt # keep on unstable — tracks nixpkgs formatting changes
    ];
}
