{ pkgs-stable, ... }:
{
  programs = {
    zoxide = {
      enable = true;
      package = pkgs-stable.zoxide;
      enableZshIntegration = true;
      enableBashIntegration = true;
      options = [
        "--cmd z"
      ];
    };
  };
}
