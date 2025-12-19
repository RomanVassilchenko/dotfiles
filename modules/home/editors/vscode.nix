{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # === Nix ===
        jnoortheen.nix-ide

        # === Go ===
        golang.go

        # === Python ===
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy

        # === Web (JS/TS) ===
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode

        # === Data/Config ===
        redhat.vscode-yaml
        tamasfe.even-better-toml
        zxh404.vscode-proto3

        # === Containers & Remote ===
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh

        # === Git & GitHub ===
        eamodio.gitlens
        github.copilot
        github.copilot-chat
        github.vscode-pull-request-github

        # === Markdown ===
        yzhang.markdown-all-in-one
        davidanson.vscode-markdownlint

        # === Utilities ===
        usernamehw.errorlens
        gruntfuggly.todo-tree
        editorconfig.editorconfig
        mechatroner.rainbow-csv
        naumovs.color-highlight
        streetsidesoftware.code-spell-checker

        # === Theme ===
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];

      userSettings = {
        # Editor
        "editor.fontSize" = 13;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font Mono', 'Droid Sans Mono', monospace";
        "editor.fontLigatures" = true;
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "selection";
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.smoothScrolling" = true;
        "editor.linkedEditing" = true;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.inlineSuggest.enabled" = true;
        "editor.stickyScroll.enabled" = true;
        "editor.wordWrap" = "on";

        # Workbench
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "workbench.startupEditor" = "none";
        "workbench.editor.enablePreview" = false;

        # Terminal
        "terminal.integrated.fontSize" = 13;
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font Mono'";
        "terminal.integrated.smoothScrolling" = true;

        # Files
        "files.autoSave" = "onFocusChange";
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;

        # Explorer
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;

        # Git
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;

        # Language-specific formatters
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        "[go]"."editor.defaultFormatter" = "golang.go";
        "[python]" = {
          "editor.defaultFormatter" = "ms-python.python";
          "editor.codeActionsOnSave"."source.organizeImports" = "explicit";
        };
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.wordWrap" = "on";
        };

        # Nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings".nixd.formatting.command = [ "nixfmt" ];

        # Go
        "go.formatTool" = "goimports";
        "go.lintTool" = "golangci-lint";

        # Extensions
        "errorLens.enabledDiagnosticLevels" = [ "error" "warning" ];
        "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];

        # Copilot
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = true;
          "scminput" = false;
        };

        # Telemetry off
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
      };
    };
  };
}
