{
  pkgs,
  lib,
  ...
}:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      # Other styles available and can be combined:
      # style = "numbers,changes,headers,rule,grid";
      style = "full";
      # Theme - Catppuccin Mocha
      theme = lib.mkForce "Catppuccin Mocha";
    };
    extraPackages = with pkgs.bat-extras; [
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
