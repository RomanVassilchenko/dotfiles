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
      # other styles available and cane be combined
      #  style = "numbers,changes,headers,rule,grid";
      style = "full";
      # Bat has other thems as well
      # ansi,Catppuccin,base16,base16-256,GitHub,Nord,etc
      theme = lib.mkForce "Dracula";
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

# {
#   pkgs,
#   lib,
#   ...
# }:
# let
#   # Override batgrep to skip tests that are failing
#   batgrep-no-check = pkgs.bat-extras.batgrep.overrideAttrs (oldAttrs: {
#     doCheck = false;
#   });
# in
# {
#   programs.bat = {
#     enable = true;
#     config = {
#       pager = "less -FR";
#       # other styles available and cane be combined
#       #  style = "numbers,changes,headers,rule,grid";
#       style = "full";
#       # Using Visual Studio Dark theme which closely matches VS Code Dark Modern
#       # Other themes: ansi,Catppuccin,base16,base16-256,GitHub,Nord,etc
#       theme = lib.mkForce "Visual Studio Dark+";
#     };
#     extraPackages = with pkgs.bat-extras; [
#       batman
#       batpipe
#       batgrep-no-check
#     ];
#   };
#   home.sessionVariables = {
#     MANPAGER = "sh -c 'col -bx | bat -l man -p'";
#     MANROFFOPT = "-c";
#   };
# }
