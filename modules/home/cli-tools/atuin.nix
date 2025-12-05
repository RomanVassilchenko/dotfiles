{ ... }:
{
  # Atuin - Magical shell history with sync, search, and statistics
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ]; # Don't override up arrow, use Ctrl+R
    settings = {
      # Search settings
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory"; # Up arrow searches in current dir
      style = "compact";
      inline_height = 20;

      # History settings
      auto_sync = false; # Disable sync (local only)
      sync_frequency = "0"; # Never sync
      sync_address = ""; # No sync server

      # Privacy
      secrets_filter = true; # Filter out secrets from history

      # UI settings
      show_preview = true;
      show_help = true;
      exit_mode = "return-original";

      # Stats
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
