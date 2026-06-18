{
  config,
  dotfiles,
  lib,
  ...
}:
let
  shared = import ./_files-shared.nix { inherit config dotfiles; };
in
{
  home.activation.cleanupAgentsSkillsParent = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    agents_skills="$HOME/.agents/skills"

    if [ -L "$agents_skills" ]; then
      agents_skills_target="$(readlink "$agents_skills" || true)"

      case "$agents_skills_target" in
        /nix/store/*-home-manager-files/.agents/skills)
          rm "$agents_skills"
          mkdir -p "$agents_skills"
          ;;
      esac
    fi
  '';

  home.file.".agents/skills/find-skills".source =
    shared.outOfStore "${shared.publicConfig}/agents/skills/find-skills";
  home.file.".agents/skills/nixos-best-practices".source =
    shared.outOfStore "${shared.publicConfig}/agents/skills/nixos-best-practices";
}
