{ pkgs-stable, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "full";
    };
    extraPackages = with pkgs-stable.bat-extras; [
      batman
      batpipe
      batgrep
    ];
  };
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
