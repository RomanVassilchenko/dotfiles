{ pkgs-stable, ... }:
{
  programs.lazygit = {
    enable = true;
    package = pkgs-stable.lazygit;
    settings = {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
      };
      gui = {
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "#89b4fa"
            "bold"
          ];
          inactiveBorderColor = [ "#6c7086" ];
          searchingActiveBorderColor = [
            "#a6adc8"
            "bold"
          ];
          optionsTextColor = [ "#f5e0dc" ];
          selectedLineBgColor = [ "#6c7086" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#6c7086" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
        };
      };
    };
  };
}
