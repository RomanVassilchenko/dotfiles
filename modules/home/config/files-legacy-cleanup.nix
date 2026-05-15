{
  config,
  dotfiles,
  lib,
  pkgs,
  ...
}:
let
  shared = import ./files-shared.nix { inherit config dotfiles; };
in
{
  home.activation.removeLegacyWholeDirectoryLinks = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    for path in "$HOME/.codex" "$HOME/.gemini" "$HOME/.config/opencode"; do
      if [ -L "$path" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$path" 2>/dev/null || true)"
        case "$target" in
          ${shared.publicConfig}/codex|${shared.publicConfig}/gemini|${shared.publicConfig}/opencode|/nix/store/*)
            ${pkgs.coreutils}/bin/rm "$path"
            ;;
        esac
      fi
    done

    for path in \
      "$HOME/.codex/AGENTS.md" \
      "$HOME/.codex/config.toml" \
      "$HOME/.codex/RTK.md" \
      "$HOME/.gemini/GEMINI.md" \
      "$HOME/.gemini/hooks/rtk-hook-gemini.sh" \
      "$HOME/.gemini/settings.json" \
      "$HOME/.config/opencode/plugins/rtk.ts"; do
      if [ -L "$path" ]; then
        ${pkgs.coreutils}/bin/rm "$path"
      fi
    done

    for path in \
      "$HOME/.codex" \
      "$HOME/.gemini/hooks" \
      "$HOME/.gemini" \
      "$HOME/.config/opencode/plugins"; do
      if [ -d "$path" ] && [ ! -L "$path" ]; then
        ${pkgs.coreutils}/bin/rmdir --ignore-fail-on-non-empty "$path"
      fi
    done

    for path in "$HOME/.agents/skills/log" "$HOME/.config/opencode/skills/log"; do
      if [ -L "$path" ]; then
        target="$(${pkgs.coreutils}/bin/readlink -f "$path" 2>/dev/null || true)"
        case "$target" in
          ${shared.publicConfig}/skills/log|${shared.publicConfig}/opencode/skills/log|/nix/store/*)
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
}
