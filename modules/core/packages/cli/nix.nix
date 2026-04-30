{
  inputs,
  pkgs,
  pkgs-stable,
  ...
}:
let
  inherit (inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}) agenix;
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
