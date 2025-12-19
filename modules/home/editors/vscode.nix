{ pkgs, inputs, ... }:
let
  # nix-vscode-extensions provides latest versions from marketplace
  # Updates automatically when you run: nix flake update
  vscode-ext = inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system};
  marketplace = vscode-ext.vscode-marketplace;
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # Allows VSCode to install/update extensions not managed by Nix
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # === Nix ===
        bbenoist.nix
        jnoortheen.nix-ide

        # === Go ===
        golang.go

        # === Python ===
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy

        # === JavaScript/TypeScript ===
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode

        # === Web Development ===
        bradlc.vscode-tailwindcss

        # === Data/Config ===
        redhat.vscode-yaml
        tamasfe.even-better-toml

        # === Containers ===
        ms-azuretools.vscode-docker

        # === Remote Development ===
        ms-vscode-remote.remote-ssh

        # === Git ===
        eamodio.gitlens
        github.copilot
        github.copilot-chat
        github.vscode-pull-request-github
        mhutchie.git-graph

        # === Markdown ===
        yzhang.markdown-all-in-one

        # === Utilities ===
        usernamehw.errorlens
        gruntfuggly.todo-tree
        editorconfig.editorconfig

        # === From marketplace (auto-updated) ===
      ] ++ [
        # Extensions not in nixpkgs - from marketplace
        marketplace.alefragnani.bookmarks
        marketplace.alexcvzz.vscode-sqlite
        marketplace.bierner.markdown-mermaid
        marketplace.catppuccin.catppuccin-vsc
        marketplace.catppuccin.catppuccin-vsc-icons
        marketplace.csstools.postcss
        marketplace.charliermarsh.ruff
        marketplace.christian-kohler.path-intellisense
        marketplace.cweijan.vscode-database-client2
        marketplace.davidanson.vscode-markdownlint
        marketplace.donjayamanne.python-environment-manager
        marketplace.dotenv.dotenv-vscode
        marketplace.earshinov.permute-lines
        marketplace.exodiusstudios.comment-anchors
        marketplace.fill-labs.dependi
        marketplace.hbenl.vscode-test-explorer
        marketplace.jock.svg
        marketplace.mechatroner.rainbow-csv
        marketplace.ms-python.black-formatter
        marketplace.ms-python.flake8
        marketplace.ms-python.isort
        marketplace.ms-vscode.test-adapter-converter
        marketplace.mtxr.sqltools
        marketplace.mtxr.sqltools-driver-pg
        marketplace.naumovs.color-highlight
        marketplace.netcorext.uuid-generator
        marketplace.nicolasvuillamy.vscode-groovy-lint
        marketplace.oderwat.indent-rainbow
        marketplace.pflannery.vscode-versionlens
        marketplace.redhat.java
        marketplace.sourcery.sourcery
        marketplace.streetsidesoftware.code-spell-checker
        marketplace.timonwong.shellcheck
        marketplace.visualstudioexptteam.intellicode-api-usage-examples
        marketplace.visualstudioexptteam.vscodeintellicode
        marketplace.vscjava.vscode-gradle
        marketplace.vscjava.vscode-java-debug
        marketplace.vscjava.vscode-java-dependency
        marketplace.vscjava.vscode-java-pack
        marketplace.vscjava.vscode-java-test
        marketplace.vscjava.vscode-maven
        marketplace.wakatime.vscode-wakatime
        marketplace.wholroyd.jinja
        marketplace.wix.vscode-import-cost
        marketplace.zxh404.vscode-proto3
      ];

      userSettings = {
        # Editor
        "editor.fontSize" = 13;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font Mono', 'Droid Sans Mono', 'monospace'";
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
        "workbench.tree.indent" = 16;

        # Terminal
        "terminal.integrated.fontSize" = 13;
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font Mono'";
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.smoothScrolling" = true;

        # Files
        "files.autoSave" = "onFocusChange";
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;

        # Explorer
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.compactFolders" = false;

        # Git
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;

        # Language-specific
        "[python]" = {
          "editor.defaultFormatter" = "charliermarsh.ruff";
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.fixAll" = "explicit";
            "source.organizeImports" = "explicit";
          };
        };
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[html]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[css]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.wordWrap" = "on";
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
        };
        "[yaml]" = {
          "editor.defaultFormatter" = "redhat.vscode-yaml";
        };

        # Extensions
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
          };
        };
        "go.formatTool" = "goimports";
        "go.lintTool" = "golangci-lint";
        "errorLens.enabledDiagnosticLevels" = [ "error" "warning" ];
        "gitlens.hovers.currentLine.over" = "line";
        "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];

        # Copilot
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = true;
          "scminput" = false;
        };

        # Telemetry
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
      };
    };
  };
}
