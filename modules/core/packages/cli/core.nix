{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # antiword
    # bc
    # catdoc
    # gzip
    # killall
    # nix-doc # Search Nix function documentation
    # nix-index - provided by nix-index-database flake in home-manager
    # pandoc
    # poppler-utils
    delta
    fd
    git
    git-absorb
    git-branchless
    jq
    just
    nixfmt
    ripgrep
    shfmt
    unrar
    unzip
    xdg-ninja
    zip
  ];
}
