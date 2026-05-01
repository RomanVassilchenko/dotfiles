{
  config,
  dotfiles,
  lib,
  pkgs,
  ...
}:
let
  dotfilesPath = dotfiles.paths.dotfiles;
  publicConfig = "${dotfilesPath}/config";
  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.activation.removeLegacyWholeDirectoryLinks = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    for path in "$HOME/.codex" "$HOME/.gemini" "$HOME/.config/opencode"; do
      if [ -L "$path" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$path" 2>/dev/null || true)"
        case "$target" in
          ${publicConfig}/codex|${publicConfig}/gemini|${publicConfig}/opencode|/nix/store/*)
            ${pkgs.coreutils}/bin/rm "$path"
            ;;
        esac
      fi
    done

    for path in "$HOME/.agents/skills/log" "$HOME/.config/opencode/skills/log"; do
      if [ -L "$path" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$path" 2>/dev/null || true)"
        case "$target" in
          ${publicConfig}/skills/log|${publicConfig}/opencode/skills/log|/nix/store/*)
            ${pkgs.coreutils}/bin/rm "$path"
            ;;
        esac
      fi
    done

    for path in "$HOME/.agents/skills" "$HOME/.config/opencode/skills"; do
      if [ -d "$path" ] && [ ! -L "$path" ]; then
        ${pkgs.coreutils}/bin/rmdir --ignore-fail-on-non-empty "$path"
      fi
    done
  '';

  home.file = {
    ".agents/skills" = {
      source = outOfStore "${publicConfig}/opencode/skills";
    };

    ".codex/AGENTS.md" = {
      source = outOfStore "${publicConfig}/codex/AGENTS.md";
    };
    ".codex/RTK.md" = {
      source = outOfStore "${publicConfig}/codex/RTK.md";
    };

    ".gemini/GEMINI.md" = {
      source = outOfStore "${publicConfig}/gemini/GEMINI.md";
    };
    ".gemini/hooks/rtk-hook-gemini.sh" = {
      source = outOfStore "${publicConfig}/gemini/hooks/rtk-hook-gemini.sh";
    };
    ".gemini/settings.json" = {
      source = outOfStore "${publicConfig}/gemini/settings.json";
    };

    ".config/rtk" = {
      source = outOfStore "${publicConfig}/rtk";
    };
    ".config/opencode/opencode.json" = {
      source = outOfStore "${publicConfig}/opencode/opencode.json";
    };
    ".config/opencode/tui.json" = {
      source = outOfStore "${publicConfig}/opencode/tui.json";
    };
    ".config/opencode/instructions/context-strategy.md" = {
      source = outOfStore "${publicConfig}/opencode/instructions/context-strategy.md";
    };
    ".config/opencode/plugins/rtk.ts" = {
      source = outOfStore "${publicConfig}/opencode/plugins/rtk.ts";
    };
    ".config/opencode/skills" = {
      source = outOfStore "${publicConfig}/opencode/skills";
    };
  };
}
