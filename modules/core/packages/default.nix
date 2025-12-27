# System packages
# CLI packages available on all systems
# Development and desktop packages only on desktop
{ ... }:
{
  imports = [
    ./cli
    ./development
    ./desktop
  ];
}
