{ inputs, ... }:
{
  imports = [ inputs.hunk.homeManagerModules.default ];

  programs.hunk = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      mode = "auto";
      line_numbers = true;
      wrap_lines = false;
      exclude_untracked = false;
    };
  };
}
