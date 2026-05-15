{
  config,
  dotfiles,
  ...
}:
let
  shared = import ./files-shared.nix { inherit config dotfiles; };
in
{
  home.file.".agents/skills".source = shared.outOfStore "${shared.publicConfig}/opencode/skills";
}
