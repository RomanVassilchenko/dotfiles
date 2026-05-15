{
  config,
  dotfiles,
  ...
}:
let
  shared = import ./files-shared.nix { inherit config dotfiles; };
in
{
  home.file = {
    ".config/opencode/opencode.json".source =
      shared.outOfStore "${shared.publicConfig}/opencode/opencode.json";
    ".config/opencode/tui.json".source = shared.outOfStore "${shared.publicConfig}/opencode/tui.json";
    ".config/opencode/instructions/context-strategy.md".source =
      shared.outOfStore "${shared.publicConfig}/opencode/instructions/context-strategy.md";
    ".config/opencode/skills".source = shared.outOfStore "${shared.publicConfig}/opencode/skills";
  };
}
