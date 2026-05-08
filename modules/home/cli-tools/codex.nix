{ pkgs, ... }:
let
  codex = pkgs.runCommand "codex-${pkgs.codex.version}-direct" { } ''
    mkdir -p $out/bin

    if [ -x ${pkgs.codex}/bin/.codex-wrapped ]; then
      cp ${pkgs.codex}/bin/.codex-wrapped $out/bin/codex
    else
      cp ${pkgs.codex}/bin/codex $out/bin/codex
    fi
    chmod +x $out/bin/codex
  '';
in
{
  home.packages = with pkgs; [
    codex
    bubblewrap
    nodejs
    ripgrep
  ];
}
