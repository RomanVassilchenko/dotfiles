{ pkgs, pkgs-stable, ... }:
{
  environment.systemPackages =
    (with pkgs-stable; [
      delta
      fd
      git-absorb
      git-branchless
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
