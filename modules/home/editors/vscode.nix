{
  dotfiles,
  lib,
  pkgs,
  config,
  ...
}:
let
  dotfilesPath = dotfiles.paths.dotfiles;
  # Pin VS Code to a working Microsoft .deb while the update server tarball is failing.
  vscodePackage = pkgs.vscode.overrideAttrs (_: {
    version = "1.116.0";
    src = pkgs.fetchurl {
      url = "https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.116.0-1776214182_amd64.deb";
      sha256 = "cb23885bdd830b83f64f259395ce5264d232666274ac999ab2de0f4e8f7995a2";
    };
    sourceRoot = "usr/share/code";
    unpackPhase = ''
      runHook preUnpack
      ${pkgs.dpkg}/bin/dpkg-deb --fsys-tarfile $src | tar --no-same-owner --no-same-permissions -xf -
      runHook postUnpack
    '';
  });
in
lib.mkIf dotfiles.features.development.enable {
  programs.vscode = {
    enable = true;
    package = vscodePackage;

    profiles.default = {
      keybindings = [
        {
          key = "ctrl+shift+g";
          command = "workbench.view.scm";
        }
        {
          key = "ctrl+/";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+i";
          command = "inlineChat.start";
          when = "editorFocus";
        }
        {
          key = "ctrl+shift+r";
          command = "opensshremotes.openEmptyWindow";
          args = "ninkear";
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
        bierner.markdown-mermaid

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
    };
  };

  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/vscode/settings.json";
}
