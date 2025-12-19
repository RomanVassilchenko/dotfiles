# Fix for KDE Plasma XDG_DATA_DIRS issue
# See: https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
#
# Problem: Qt wrapper scripts inject XDG_DATA_DIRS at runtime, causing
# Plasma to fail finding icons, themes, and other XDG resources.
#
# Solution: Pre-merge all XDG_DATA_DIRS content at build time into a single
# directory, then inject that static path instead of the dynamic one.
{ pkgs, lib, ... }:
{
  nixpkgs.overlays = lib.singleton (
    final: prev: {
      kdePackages = prev.kdePackages // {
        plasma-workspace =
          let
            basePkg = prev.kdePackages.plasma-workspace;

            # Helper package that merges all XDG_DATA_DIRS into a single directory
            xdgdataPkg = pkgs.stdenv.mkDerivation {
              name = "${basePkg.name}-xdgdata";
              buildInputs = [ basePkg ];
              dontUnpack = true;
              dontFixup = true;
              dontWrapQtApps = true;
              installPhase = ''
                mkdir -p $out/share
                ( IFS=:
                  for DIR in $XDG_DATA_DIRS; do
                    if [[ -d "$DIR" ]]; then
                      cp -r $DIR/. $out/share/
                      chmod -R u+w $out/share
                    fi
                  done
                )
              '';
            };

            # Override plasma-workspace to use the pre-merged XDG data
            derivedPkg = basePkg.overrideAttrs {
              preFixup = ''
                # Remove the dynamic XDG_DATA_DIRS injection from qtWrapperArgs
                for index in "''${!qtWrapperArgs[@]}"; do
                  if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                    unset -v "qtWrapperArgs[$((index+0))]"
                    unset -v "qtWrapperArgs[$((index+1))]"
                    unset -v "qtWrapperArgs[$((index+2))]"
                    unset -v "qtWrapperArgs[$((index+3))]"
                  fi
                done
                # Rebuild array without gaps
                qtWrapperArgs=("''${qtWrapperArgs[@]}")
                # Inject pre-built merged XDG data directory
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
              '';
            };
          in
          derivedPkg;
      };
    }
  );
}
