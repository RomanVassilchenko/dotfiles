{ pkgs, ... }:
let
  codex =
    pkgs.runCommand "codex-${pkgs.codex.version}-unhidden-wrapper"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p $out/bin

        cp ${pkgs.codex}/bin/.codex-wrapped $out/bin/codex-bin
        chmod +x $out/bin/codex-bin

        makeWrapper $out/bin/codex-bin $out/bin/codex \
          --prefix PATH : ${
            pkgs.lib.escapeShellArg (
              pkgs.lib.makeBinPath [
                pkgs.ripgrep
                pkgs.bubblewrap
              ]
            )
          }
      '';
in
{
  home.packages = with pkgs; [
    codex
    nodejs
  ];
}
