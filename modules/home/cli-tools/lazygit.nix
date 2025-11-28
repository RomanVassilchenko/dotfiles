# Lazygit is a simple terminal UI for git commands.
{ lib, ... }:
let
  accent = "#89b4fa"; # Blue accent
  muted = "#6c7086"; # Muted gray
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
            accent
            "bold"
          ];
          inactiveBorderColor = [ muted ];
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
