{ pkgs, ... }:
{
  # CLI database tools (system-wide)
  # GUI apps (dbeaver) are in modules/home/apps/*.nix
  environment.systemPackages = with pkgs; [
    postgresql
    squawk
  ];
}
