{ pkgs-stable, ... }:
{
  environment.systemPackages = with pkgs-stable; [
    bottom
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
