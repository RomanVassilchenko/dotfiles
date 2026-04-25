{
  inputs,
  pkgs,
  pkgs-stable,
  ...
}:
let
  agenix = inputs.agenix.packages.${pkgs.system}.agenix;
  agenix-rekey = pkgs.writeShellApplication {
    name = "agenix-rekey";
    runtimeInputs = [ agenix ];
    text = ''
      exec agenix -r "$@"
    '';
  };
in
{
  environment.systemPackages = [
    agenix-rekey
    pkgs.nix-diff
    pkgs.nix-fast-build
    pkgs.nix-tree
    pkgs.statix
    pkgs-stable.deadnix
    pkgs-stable.nh
  ];
}
