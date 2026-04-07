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
      os = {
        edit = "micro {{filename}}";
        editAtLine = "micro +{{line}} {{filename}}";
      };
      refilterMode = "subsequence";
      gui = {
        border = "rounded";
        showFileTree = true;
        showIcons = true;
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        showPanelJumps = false;
        branchColors = {
          "main" = "#f38ba8";
          "master" = "#f38ba8";
          "develop" = "#89b4fa";
        };
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "#cba6f7"
            "bold"
          ];
          inactiveBorderColor = [ "#6c7086" ];
          searchingActiveBorderColor = [
            "#a6adc8"
            "bold"
          ];
          optionsTextColor = [ "#f5e0dc" ];
          selectedLineBgColor = [ "#6c7086" ];
          selectedRangeBgColor = [ "#45475a" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#6c7086" ];
          unstagedChangesColor = [ "#f38ba8" ];
          stagedChangesColor = [ "#a6e3a1" ];
          inactiveViewSelectedLineBgColor = [ "#313244" ];
          defaultFgColor = [ "#cdd6f4" ];
        };
      };
    };
  };
}
