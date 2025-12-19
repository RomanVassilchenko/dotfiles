{ pkgs, ... }:
{
  home.packages = [ pkgs.nixd ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      keybindings = [
        {
          key = "ctrl+shift+g";
          command = "workbench.view.scm";
        }
      ];

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
        redhat.vscode-xml
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
        foxundermoon.shell-format

        # === Theme ===
        pkief.material-icon-theme
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];

      userSettings = {
        # Language-specific formatters
        "[css]"."editor.defaultFormatter" = "vscode.css-language-features";
        "[dockercompose]" = {
          "editor.autoIndent" = "advanced";
          "editor.defaultFormatter" = "redhat.vscode-yaml";
          "editor.insertSpaces" = true;
          "editor.quickSuggestions" = {
            "comments" = false;
            "other" = true;
            "strings" = true;
          };
          "editor.tabSize" = 2;
        };
        "[github-actions-workflow]"."editor.defaultFormatter" = "redhat.vscode-yaml";
        "[go]" = {
          "editor.minimap.maxColumn" = 80;
          "editor.rulers" = [ 80 ];
        };
        "[html]"."editor.defaultFormatter" = "vscode.html-language-features";
        "[javascript]"."editor.defaultFormatter" = "vscode.typescript-language-features";
        "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
        "[jsonc]"."editor.defaultFormatter" = "vscode.json-language-features";
        "[markdown]" = {
          "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
          "files.trimTrailingWhitespace" = false;
        };
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        "[proto3]"."editor.defaultFormatter" = "zxh404.vscode-proto3";
        "[shellscript]"."editor.defaultFormatter" = "foxundermoon.shell-format";
        "[xml]"."editor.defaultFormatter" = "redhat.vscode-xml";
        "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";

        # Breadcrumbs
        "breadcrumbs.enabled" = false;

        # Chat
        "chat.editor.fontFamily" = "JetBrainsMono Nerd Font Propo";
        "chat.fontFamily" = "JetBrainsMono Nerd Font Propo";

        # Claude Code
        "claudeCode.preferredLocation" = "panel";
        "claudeCode.useTerminal" = true;

        # Debug
        "debug.console.fontFamily" = "JetBrainsMono Nerd Font Propo";

        # Diff Editor
        "diffEditor.experimental.showMoves" = true;
        "diffEditor.hideUnchangedRegions.enabled" = true;
        "diffEditor.ignoreTrimWhitespace" = false;
        "diffEditor.maxComputationTime" = 0;
        "diffEditor.wordWrap" = "on";

        # Docker
        "docker.extension.enableComposeLanguageServer" = true;

        # Editor
        "editor.accessibilitySupport" = "off";
        "editor.bracketPairColorization.enabled" = true;
        "editor.codeActionsOnSave" = {
          "source.fixAll" = "always";
          "source.fixAll.eslint" = "always";
          "source.fixAll.markdownlint" = "always";
          "source.fixAll.sortJSON" = "never";
          "source.generate.finalModifiers" = "always";
          "source.organizeImports" = "always";
          "source.sortMembers" = "always";
        };
        "editor.codeLensFontFamily" = "JetBrainsMono Nerd Font Propo";
        "editor.colorDecorators" = true;
        "editor.copyWithSyntaxHighlighting" = false;
        "editor.cursorBlinking" = "expand";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.cursorSurroundingLines" = 2;
        "editor.defaultFormatter" = "golang.go";
        "editor.detectIndentation" = true;
        "editor.emptySelectionClipboard" = false;
        "editor.find.seedSearchStringFromSelection" = "selection";
        "editor.fontFamily" = "JetBrainsMono Nerd Font Propo";
        "editor.fontLigatures" = true;
        "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnType" = true;
        "editor.guides.bracketPairs" = true;
        "editor.guides.indentation" = true;
        "editor.hideCursorInOverviewRuler" = true;
        "editor.hover.delay" = 300;
        "editor.hover.enabled" = "on";
        "editor.inlineSuggest.enabled" = true;
        "editor.inlineSuggest.fontFamily" = "JetBrainsMono Nerd Font Propo";
        "editor.insertSpaces" = true;
        "editor.largeFileOptimizations" = false;
        "editor.lightbulb.enabled" = "on";
        "editor.linkedEditing" = true;
        "editor.matchBrackets" = "always";
        "editor.minimap.enabled" = false;
        "editor.minimap.showMarkSectionHeaders" = false;
        "editor.occurrencesHighlight" = "off";
        "editor.overviewRulerBorder" = false;
        "editor.padding.top" = 20;
        "editor.padding.bottom" = 20;
        "editor.renderControlCharacters" = false;
        "editor.renderLineHighlight" = "none";
        "editor.rulers" = [
          80
          120
        ];
        "editor.scrollbar.horizontal" = "auto";
        "editor.scrollbar.vertical" = "auto";
        "editor.selectionHighlight" = false;
        "editor.semanticHighlighting.enabled" = true;
        "editor.smoothScrolling" = true;
        "editor.snippetSuggestions" = "top";
        "editor.stickyScroll.enabled" = true;
        "editor.suggestSelection" = "first";
        "editor.tabSize" = 2;
        "editor.unicodeHighlight.allowedCharacters"."×" = true;
        "editor.unicodeHighlight.ambiguousCharacters" = false;
        "editor.wordWrap" = "on";
        "editor.wordWrapColumn" = 120;

        # Emmet
        "emmet.triggerExpansionOnTab" = true;

        # Error Lens
        "errorLens.enabled" = true;
        "errorLens.fontFamily" = "JetBrainsMono Nerd Font";

        # Explorer
        "explorer.autoReveal" = true;
        "explorer.compactFolders" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.copyRelativePathSeparator" = "/";
        "explorer.decorations.badges" = false;
        "explorer.fileNesting.enabled" = true;
        "explorer.incrementalNaming" = "smart";
        "explorer.openEditors.sortOrder" = "alphabetical";

        # Extensions
        "extensions.ignoreRecommendations" = true;

        # Files
        "files.autoSave" = "onFocusChange";
        "files.exclude" = {
          ".idea" = true;
          ".metadata" = true;
          ".vscode" = true;
          "**/._*" = true;
          "**/.DS_Store" = true;
          "**/.git" = true;
          "**/.gitignore" = true;
          "**/.hg" = true;
          "**/.svn" = true;
          "**/CVS" = true;
          "**/node_modules" = true;
          "**/Thumbs.db" = true;
        };
        "files.insertFinalNewline" = true;
        "files.restoreUndoStack" = false;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;

        # Git
        "git.allowForcePush" = true;
        "git.autofetch" = true;
        "git.autoRepositoryDetection" = "subFolders";
        "git.autoStash" = true;
        "git.blame.editorDecoration.enabled" = true;
        "git.confirmForcePush" = false;
        "git.confirmSync" = false;
        "git.decorations.enabled" = false;
        "git.enableSmartCommit" = true;
        "git.ignoreMissingGitWarning" = true;
        "git.inputValidationLength" = 80;
        "git.inputValidationSubjectLength" = 80;
        "git.pruneOnFetch" = true;
        "git.pullBeforeCheckout" = true;
        "git.replaceTagsWhenPull" = true;
        "git.repositoryScanMaxDepth" = 4;
        "git.timeline.showUncommitted" = true;

        # GitHub Copilot
        "github.copilot.chat.agent.thinkingTool" = true;
        "github.copilot.chat.commitMessageGeneration.instructions" = [ ];
        "github.copilot.chat.editor.temporalContext.enabled" = true;
        "github.copilot.chat.generateTests.codeLens" = true;
        "github.copilot.chat.localeOverride" = "auto";
        "github.copilot.enable" = {
          "*" = true;
          "markdown" = true;
          "plaintext" = true;
          "scminput" = true;
        };
        "github.copilot.nextEditSuggestions.enabled" = true;
        "github.gitProtocol" = "ssh";

        # GitHub Pull Requests
        "githubPullRequests.assignCreated" = "\${user}";
        "githubPullRequests.commentExpandState" = "collapseAll";
        "githubPullRequests.createDefaultBaseBranch" = "createdFromBranch";
        "githubPullRequests.defaultMergeMethod" = "squash";
        "githubPullRequests.experimental.chat" = true;
        "githubPullRequests.pullBranch" = "always";
        "githubPullRequests.pullRequestDescription" = "template";
        "githubPullRequests.pushBranch" = "always";
        "githubPullRequests.remotes" = [ "origin" ];

        # Go
        "go.inlayHints.compositeLiteralFields" = true;
        "go.inlayHints.compositeLiteralTypes" = true;
        "go.inlayHints.constantValues" = true;
        "go.inlayHints.functionTypeParameters" = true;
        "go.inlayHints.parameterNames" = true;
        "go.inlayHints.rangeVariableTypes" = true;
        "go.lintTool" = "golangci-lint";
        "go.toolsManagement.autoUpdate" = false;
        "go.useLanguageServer" = true;
        "gopls"."formatting.gofumpt" = true;

        # Markdown
        "markdown.editor.pasteUrlAsFormattedLink.enabled" = "never";
        "markdown.preview.fontFamily" = "JetBrainsMono Nerd Font Propo";
        "markdownlint.config" = {
          "first-line-heading" = false;
          "no-blanks-blockquote" = false;
          "no-duplicate-heading" = false;
          "no-hard-tabs" = false;
          "no-inline-html" = false;
          "reference-links-images" = false;
        };

        # Material Icon Theme
        "material-icon-theme.hidesExplorerArrows" = true;

        # Problems
        "problems.decorations.enabled" = false;

        # Protobuf
        "protobuf.externalLinter.bufPath" = "buf";
        "protobuf.externalLinter.enabled" = true;
        "protobuf.externalLinter.linter" = "buf";

        # Nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings".nixd.formatting.command = [ "nixfmt" ];

        # References
        "references.preferredLocation" = "view";

        # SCM
        "scm.defaultViewMode" = "tree";
        "scm.inputFontFamily" = "";

        # Security
        "security.workspace.trust.enabled" = false;

        # Spell checker
        "spellright.language" = [
          "en"
          "ru"
        ];

        # Telemetry
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;

        # Terminal
        "terminal.external.linuxExec" = "ghostty";
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "terminal.integrated.enableImages" = true;
        "terminal.integrated.enableMultiLinePasteWarning" = "never";
        "terminal.integrated.fontLigatures.enabled" = true;
        "terminal.integrated.hideOnStartup" = "whenEmpty";
        "terminal.integrated.minimumContrastRatio" = 4.5;
        "terminal.integrated.scrollback" = 10000;
        "terminal.integrated.showExitAlert" = false;
        "terminal.integrated.smoothScrolling" = true;
        "terminal.integrated.stickyScroll.enabled" = false;
        "terminal.integrated.suggest.enabled" = true;
        "terminal.integrated.tabs.focusMode" = "singleClick";
        "terminal.integrated.tabStopWidth" = 2;

        # Update
        "update.mode" = "manual";

        # Window
        "window.customMenuBarAltFocus" = false;
        "window.customTitleBarVisibility" = "never";
        "window.dialogStyle" = "custom";
        "window.enableMenuBarMnemonics" = false;
        "window.menuBarVisibility" = "toggle";
        "window.newWindowDimensions" = "inherit";
        "window.restoreFullscreen" = true;
        "window.restoreWindows" = "all";
        "window.title" = "\${rootName}\${separator}\${activeEditorShort}";
        "window.titleBarStyle" = "native";

        # Workbench
        "workbench.activityBar.location" = "hidden";
        "workbench.colorCustomizations" = {
          "editorCursor.background" = "#000000";
          "editorOverviewRuler.addedForeground" = "#0000";
          "editorOverviewRuler.border" = "#0000";
          "editorOverviewRuler.bracketMatchForeground" = "#0000";
          "editorOverviewRuler.deletedForeground" = "#0000";
          "editorOverviewRuler.errorForeground" = "#0000";
          "editorOverviewRuler.findMatchForeground" = "#0000";
          "editorOverviewRuler.infoForeground" = "#0000";
          "editorOverviewRuler.modifiedForeground" = "#0000";
          "editorOverviewRuler.rangeHighlightForeground" = "#0000";
          "editorOverviewRuler.selectionHighlightForeground" = "#0000";
          "editorOverviewRuler.warningForeground" = "#0000";
          "editorOverviewRuler.wordHighlightForeground" = "#0000";
          "editorOverviewRuler.wordHighlightStrongForeground" = "#0000";
        };
        "workbench.editor.enablePreview" = false;
        "workbench.editor.highlightModifiedTabs" = true;
        "workbench.editor.pinnedTabSizing" = "normal";
        "workbench.editor.revealIfOpen" = true;
        "workbench.editor.showTabs" = "multiple";
        "workbench.editor.tabSizing" = "fit";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "workbench.layoutControl.enabled" = false;
        "workbench.list.smoothScrolling" = true;
        "workbench.navigationControl.enabled" = false;
        "workbench.productIconTheme" = "material-product-icons";
        "workbench.settings.editor" = "json";
        "workbench.settings.openDefaultKeybindings" = true;
        "workbench.settings.useSplitJSON" = false;
        "workbench.sideBar.location" = "right";
        "workbench.statusBar.visible" = false;
        "workbench.tips.enabled" = false;
        "workbench.tree.enableStickyScroll" = true;
        "workbench.tree.indent" = 14;
        "workbench.tree.renderIndentGuides" = "always";

        # XML
        "xml.format.preservedNewlines" = 1;

        # Zen Mode
        "zenMode.centerLayout" = true;
        "zenMode.hideActivityBar" = false;
      };
    };
  };
}
