{ pkgs-stable, ... }:
{
  programs.atuin = {
    enable = true;
    package = pkgs-stable.atuin;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      search_mode = "fuzzy";
      filter_mode = "directory";
      style = "compact";
      inline_height = 18;

      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "http://100.64.0.1:8888";
      secrets_filter = true;

      show_preview = true;
      show_help = false;
      enter_accept = false;
      exit_mode = "return-original";
      workspaces = true;
      prefers_reduced_motion = true;

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
