{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    bottom
    carapace
    choose
    hyperfine
    jc
    ouch
    procs
    sd
    tokei
    watchexec
    yazi
  ];
}
