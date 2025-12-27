# Core system configuration
# Each subfolder has its own default.nix with import logic
{ ... }:
{
  imports = [
    ./system
    ./security
    ./tools
    ./packages
    ./services
    ./desktop
  ];
}
