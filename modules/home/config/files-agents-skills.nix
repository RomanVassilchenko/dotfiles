{
  config,
  dotfiles,
  ...
}:
let
  shared = import ./files-shared.nix { inherit config dotfiles; };
in
{
  home.file.".agents/skills/find-skills".source =
    shared.outOfStore "${shared.publicConfig}/agents/skills/find-skills";
  home.file.".agents/skills/nixos-best-practices".source =
    shared.outOfStore "${shared.publicConfig}/agents/skills/nixos-best-practices";
}
