{ pkgs, ... }:
{
  # Nix-index - Locate packages providing a specific file
  # Also provides command-not-found integration
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # Use nix-index-database for pre-built index (faster than building locally)
  # The database is updated weekly
  home.packages = [ pkgs.nix-index ];

  # Command-not-found hook is automatically enabled with enableZshIntegration
  # When you type a command that doesn't exist, it will suggest which package to install
}
