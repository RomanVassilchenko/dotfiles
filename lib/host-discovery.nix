{ inputs }:
let
  inherit (inputs.nixpkgs) lib;

  publicHostsDir = ../hosts;
  privateHostsDir = ../private/hosts;
  excluded = [
    "default"
    "profiles"
    "template"
  ];

  namesFrom =
    hostsDir: requireHardware:
    lib.attrNames (
      lib.filterAttrs (
        name: type:
        type == "directory"
        && !(builtins.elem name excluded)
        && builtins.pathExists (hostsDir + "/${name}/default.nix")
        && (!requireHardware || builtins.pathExists (hostsDir + "/${name}/hardware.nix"))
      ) (builtins.readDir hostsDir)
    );

  publicHosts = namesFrom publicHostsDir true;
  privateHosts = if builtins.pathExists privateHostsDir then namesFrom privateHostsDir false else [ ];
in
{
  inherit
    publicHostsDir
    privateHostsDir
    publicHosts
    privateHosts
    excluded
    ;

  hostNames = lib.unique (publicHosts ++ privateHosts);

  describeHost =
    host:
    let
      publicHostPath = publicHostsDir + "/${host}";
      privateHostPath = privateHostsDir + "/${host}";
    in
    {
      name = host;
      publicDefault = builtins.pathExists (publicHostPath + "/default.nix");
      publicHardware = builtins.pathExists (publicHostPath + "/hardware.nix");
      privateDefault = builtins.pathExists (privateHostPath + "/default.nix");
      privateHardware = builtins.pathExists (privateHostPath + "/hardware.nix");
      enabled = builtins.elem host (lib.unique (publicHosts ++ privateHosts));
    };
}
