# Eza is a ls replacement with Catppuccin Mocha theme
let
  # Catppuccin Mocha colors with Mauve accent for EZA_COLORS
  ezaColors = builtins.concatStringsSep ":" [
    # Permissions - using Catppuccin colors
    "ur=38;2;166;227;161" # user read - green
    "uw=38;2;243;139;168" # user write - red
    "ux=38;2;203;166;247" # user exec - mauve
    "ue=38;2;203;166;247" # user exec file - mauve
    "gr=38;2;249;226;175" # group read - yellow
    "gw=38;2;243;139;168" # group write - red
    "gx=38;2;203;166;247" # group exec - mauve
    "tr=38;2;249;226;175" # other read - yellow
    "tw=38;2;243;139;168" # other write - red
    "tx=38;2;203;166;247" # other exec - mauve
    # Special
    "su=38;2;243;139;168" # setuid - red
    "sf=38;2;243;139;168" # setgid - red
    # File size
    "sn=38;2;166;227;161" # size number - green
    "sb=38;2;166;227;161" # size unit - green
    # Dates
    "da=38;2;137;180;250" # date - blue
    # Git
    "ga=38;2;166;227;161" # git new - green
    "gm=38;2;249;226;175" # git modified - yellow
    "gd=38;2;243;139;168" # git deleted - red
    "gv=38;2;148;226;213" # git renamed - teal
    "gt=38;2;108;112;134" # git ignored - overlay0
    # Names
    "di=38;2;203;166;247;1" # directory - mauve bold
    "ex=38;2;166;227;161" # executable - green
    "fi=38;2;205;214;244" # file - text
    "ln=38;2;148;226;213" # symlink - teal
    "or=38;2;243;139;168" # broken symlink - red
    # Header
    "hd=38;2;108;112;134;4" # header - overlay0 underline
  ];
in
{
  programs.eza = {
    enable = true;
    icons = "auto";
    enableZshIntegration = true;
    git = true;

    extraOptions = [
      "--group-directories-first"
      "--no-quotes"
      "--header" # Show header row
      "--git-ignore"
      "--icons=always"
      # "--time-style=long-iso" # ISO 8601 extended format for time
      "--classify" # append indicator (/, *, =, @, |)
      "--hyperlink" # make paths clickable in some terminals
      "--color=always"
    ];
  };

  # Set EZA_COLORS environment variable for Catppuccin theme
  home.sessionVariables.EZA_COLORS = ezaColors;

  # Aliases to make `ls`, `ll`, `la` use eza
  home.shellAliases = {
    ls = "eza";
    lt = "eza --tree --level=2";
    ll = "eza  -lh --no-user --long";
    la = "eza -lah ";
    tree = "eza --tree ";
  };
}
