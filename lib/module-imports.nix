{ lib }:
let
  isEnabledNixFile =
    name: type:
    type == "regular"
    && lib.hasSuffix ".nix" name
    && name != "default.nix"
    && !(lib.hasPrefix "_" name);

  filesIn =
    dir:
    map (name: dir + "/${name}") (
      lib.sort lib.lessThan (lib.attrNames (lib.filterAttrs isEnabledNixFile (builtins.readDir dir)))
    );
in
{
  inherit filesIn;

  filesInDirs = dirs: lib.concatMap filesIn dirs;
}
