{ pkgs-stable, ... }:
{
  programs.direnv = {
    enable = true;
    package = pkgs-stable.direnv;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    silent = true;
  };
}
