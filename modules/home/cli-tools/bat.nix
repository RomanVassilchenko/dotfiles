{ pkgs-stable, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "numbers,changes,header";
      tabs = "2";
      wrap = "never";
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
