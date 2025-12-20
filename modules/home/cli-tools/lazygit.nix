# Lazygit is a simple terminal UI for git commands.
{ lib, ... }:
let
  # Catppuccin Mocha colors - using mauve for consistency
  mauve = "#cba6f7"; # Primary accent (matches system theme)
  overlay0 = "#6c7086"; # Muted text
  surface0 = "#313244"; # Background highlight
  text = "#cdd6f4"; # Main text
in
{
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
      };
      gui = {
        theme = {
          activeBorderColor = [
            mauve
            "bold"
          ];
          inactiveBorderColor = [ overlay0 ];
          selectedLineBgColor = [ surface0 ];
          optionsTextColor = [ mauve ];
        };
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
