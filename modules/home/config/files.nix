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
    for path in "$HOME/.claude" "$HOME/.codex" "$HOME/.gemini" "$HOME/.config/opencode"; do
      if [ -L "$path" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$path" 2>/dev/null || true)"
        case "$target" in
          ${publicConfig}/.claude|${publicConfig}/codex|${publicConfig}/gemini|${publicConfig}/opencode|/nix/store/*)
            ${pkgs.coreutils}/bin/rm "$path"
            ;;
        esac
      fi
    done

    old_global_skill="$HOME/.claude/skills/dotfiles-release"
    if [ -L "$old_global_skill" ]; then
      target="$(${pkgs.coreutils}/bin/readlink -f "$old_global_skill" 2>/dev/null || true)"
      case "$target" in
        ${publicConfig}/.claude/skills/dotfiles-release|/nix/store/*)
          ${pkgs.coreutils}/bin/rm "$old_global_skill"
          ;;
      esac
    fi

    for path in "$HOME/.claude/skills/log" "$HOME/.agents/skills/log" "$HOME/.config/opencode/skills/log"; do
      if [ -L "$path" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$path" 2>/dev/null || true)"
        case "$target" in
          ${publicConfig}/.claude/skills/log|${publicConfig}/skills/log|${publicConfig}/opencode/skills/log|/nix/store/*)
            ${pkgs.coreutils}/bin/rm "$path"
            ;;
        esac
      fi
    done

    for path in "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.config/opencode/skills"; do
      if [ -d "$path" ] && [ ! -L "$path" ]; then
        ${pkgs.coreutils}/bin/rmdir --ignore-fail-on-non-empty "$path"
      fi
    done
  '';

  home.file = {
    ".claude/CLAUDE.md" = {
      source = outOfStore "${publicConfig}/.claude/CLAUDE.md";
    };
    ".claude/RTK.md" = {
      source = outOfStore "${publicConfig}/.claude/RTK.md";
    };
    ".claude/hooks/rtk-rewrite.sh" = {
      source = outOfStore "${publicConfig}/.claude/hooks/rtk-rewrite.sh";
    };
    ".claude/settings.json" = {
      source = outOfStore "${publicConfig}/.claude/settings.json";
    };
    ".claude/skills" = {
      source = outOfStore "${publicConfig}/opencode/skills";
    };
    ".claude/statusline-command.sh" = {
      source = outOfStore "${publicConfig}/.claude/statusline-command.sh";
    };

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
    ".config/opencode/instructions/shell-strategy.md" = {
      source = outOfStore "${publicConfig}/opencode/instructions/shell-strategy.md";
    };
    ".config/opencode/plugins/rtk.ts" = {
      source = outOfStore "${publicConfig}/opencode/plugins/rtk.ts";
    };
    ".config/opencode/skills" = {
      source = outOfStore "${publicConfig}/opencode/skills";
    };
  };
}
