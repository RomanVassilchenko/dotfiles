# User configuration - git, ssh, xdg
{
  lib,
  isServer,
  ...
}:
{
  imports =
    [
      # Core config (all systems)
      ./git.nix
      ./git-secrets-generator.nix
      ./ssh.nix
      ./ssh-secrets-generator.nix
      ./xdg.nix
    ]
    ++ lib.optionals (!isServer) [
      # Stylix overrides (desktop only)
      ./stylix.nix
    ];
}
