{ ... }:
{
  imports = [
    ./desktop-entry.nix
    ./power-and-shortcuts.nix
    ./config-core.nix
    ./config-kwin.nix
    ./config-misc.nix
  ];
}
