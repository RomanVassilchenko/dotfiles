{ pkgs-stable, ... }:
{
  programs.atuin = {
    enable = true;
    package = pkgs-stable.atuin;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";
      inline_height = 20;

      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "http://100.64.0.1:8888";
      secrets_filter = true;

      show_preview = true;
      show_help = false;
      enter_accept = false;
      exit_mode = "return-original";

      stats = {
        common_subcommands = [
          "git"
          "cargo"
          "npm"
          "pnpm"
          "yarn"
          "docker"
          "kubectl"
          "nix"
        ];
      };
    };
  };
}
