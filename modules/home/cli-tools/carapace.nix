{ pkgs-stable, ... }:
{
  programs.carapace = {
    enable = true;
    package = pkgs-stable.carapace;
    enableZshIntegration = true;
  };
}
