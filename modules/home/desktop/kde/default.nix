{ lib, ... }:
let
  moduleImports = import ../../../../lib/module-imports.nix { inherit lib; };
in
{
  imports = moduleImports.filesIn ./. ++ moduleImports.filesIn ./kwin;
}
