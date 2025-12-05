{ ... }:
{
  # Direnv - Automatic environment switching for project directories
  # Usage: Create a .envrc file in your project with "use flake" or "use nix"
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Better Nix integration with caching
    silent = true; # Don't show direnv messages (less noisy)
    config = {
      global = {
        load_dotenv = true; # Automatically load .env files
        strict_env = true; # Fail on undefined variables
        warn_timeout = "30s";
      };
    };
  };
}
