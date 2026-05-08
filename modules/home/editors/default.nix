{
  dotfiles,
  lib,
  pkgs,
  ...
}:
let
  orqflowRoot = "/home/romanv/Projects/OrqFlow";
  vscodeExtensionSource = "${orqflowRoot}/editors/vscode/orqflow-syntax";

  orqlsp = pkgs.writeShellScriptBin "orqlsp" ''
    set -eu

    root="''${ORQFLOW_ROOT:-${orqflowRoot}}"

    if [ -x "$root/bin/orqlsp" ]; then
      exec "$root/bin/orqlsp" "$@"
    fi

    if [ -f "$root/go.mod" ]; then
      cd "$root"
      exec ${pkgs.go}/bin/go run ./cmd/orqlsp "$@"
    fi

    printf 'orqlsp: OrqFlow checkout not found at %s\n' "$root" >&2
    exit 1
  '';
in
{
  imports = [
    ./micro.nix
    ./vscode.nix
    ./zed.nix
  ];

  config = lib.mkIf dotfiles.features.development.enable {
    home.packages = [
      orqlsp
    ];

    home.activation.installOrqFlowEditorExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      vscode_target="$HOME/.vscode/extensions/qaralabs.orqflow-syntax-0.1.0"
      zed_target="$HOME/.local/share/zed/extensions/installed/orqflow"

      ${pkgs.coreutils}/bin/install -d "$HOME/.vscode/extensions"
      if [ -L "$zed_target" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$zed_target" 2>/dev/null || true)"
        if [ "$target" = "${orqflowRoot}/editors/zed/orqflow" ]; then
          ${pkgs.coreutils}/bin/rm "$zed_target"
        fi
      fi

      if [ -e "$vscode_target" ] && [ ! -L "$vscode_target" ]; then
        printf 'OrqFlow VS Code extension target exists and is not a symlink: %s\n' "$vscode_target" >&2
      else
        ${pkgs.coreutils}/bin/ln -sfn ${lib.escapeShellArg vscodeExtensionSource} "$vscode_target"
      fi

      vscode_extensions_json="$HOME/.vscode/extensions/extensions.json"
      if [ ! -e "$vscode_extensions_json" ]; then
        printf '[]\n' > "$vscode_extensions_json"
      fi
      if [ -e "$vscode_extensions_json" ]; then
        ${pkgs.jq}/bin/jq \
          --arg id "qaralabs.orqflow-syntax" \
          --arg version "0.1.0" \
          --arg path "$vscode_target" \
          --arg relativeLocation "qaralabs.orqflow-syntax-0.1.0" \
          'map(select(.identifier.id != $id)) + [{
            identifier: { id: $id },
            version: $version,
            location: { "$mid": 1, path: $path, scheme: "file" },
            relativeLocation: $relativeLocation
          }]' \
          "$vscode_extensions_json" > "$vscode_extensions_json.tmp"
        ${pkgs.coreutils}/bin/mv "$vscode_extensions_json.tmp" "$vscode_extensions_json"
      fi
    '';
  };
}
