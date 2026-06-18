{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  hostDiscovery = import ../lib/host-discovery.nix { inherit inputs; };
  moduleImports = import ../lib/module-imports.nix { inherit lib; };
  packageSets = import ../lib/package-sets.nix { inherit inputs; };
  inherit (hostDiscovery) publicHostsDir privateHostsDir hostNames;
  hostDefaults = import ../hosts/default/common.nix;
  freerdpRdpCamOverlay = import ../lib/overlays/freerdp-rdpecam.nix;

  gpuConfig = {
    intel = {
      drivers.intel.enable = true;
    };
    amd = {
      drivers.amdgpu.enable = true;
    };
  };

  coreModuleDirs = [
    ../modules/drivers
    ../modules/core/desktop
    ../modules/core/packages/cli
    ../modules/core/packages/development
    ../modules/core/packages/desktop
    ../modules/core/services
    ../modules/core/services/server
    ../modules/core/system
    ../modules/core/tools
  ];

  mkHost =
    host:
    let
      publicHostPath = publicHostsDir + "/${host}";
      privateHostPath = privateHostsDir + "/${host}";
      hasPublicHost = builtins.pathExists (publicHostPath + "/default.nix");
      hasPrivateHost = builtins.pathExists (privateHostPath + "/default.nix");
      publicHostModule = if hasPublicHost then import publicHostPath else { };
      privateHostModule = if hasPrivateHost then import privateHostPath else { };
      hostConfig = lib.recursiveUpdate (lib.recursiveUpdate hostDefaults (
        publicHostModule.dotfiles or { }
      )) (privateHostModule.dotfiles or { });
      system = hostConfig.host.system or "x86_64-linux";
      profile = hostConfig.host.profile or "workstation";
      deviceType = hostConfig.host.deviceType or (if profile == "server" then "server" else "laptop");
      gpuProfile = hostConfig.host.gpuProfile or null;
      username = hostConfig.user.name or "youruser";
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          username
          host
          ;
        hostDefaults = hostDefaults;
        pkgs-bitwarden = packageSets.mkBitwarden system;
        pkgs-stable = packageSets.mkStable system;
      };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.llm-agents.overlays.default
            freerdpRdpCamOverlay
          ];
        }
        ../features/apps/default.nix
        ../features/communication/default.nix
        ../features/desktop/default.nix
        ../features/development/default.nix
        ../features/kde/default.nix
        ../features/printing/default.nix
        ../features/productivity/default.nix
        ../features/stylix/default.nix
        ../features/work/default.nix
      ]
      ++ moduleImports.filesInDirs coreModuleDirs
      ++ lib.optional hasPublicHost publicHostPath
      ++ lib.optional hasPrivateHost privateHostPath
      ++ lib.optional (gpuProfile != null) gpuConfig.${gpuProfile}
      ++ [
        inputs.stylix.nixosModules.stylix
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.helium-browser.nixosModules.default
      ]
      ++ lib.optional (builtins.pathExists ../private/default.nix) ../private;
    };
in
{
  perSystem =
    { pkgs, ... }:
    let
      dotCli = import ../lib/dot-cli.nix { inherit pkgs; };
    in
    {
      packages.dot = dotCli;
      formatter = pkgs.nixfmt-tree;
      apps.dot = {
        type = "app";
        program = "${dotCli}/bin/dot";
        meta.description = "Manage and rebuild these NixOS dotfiles";
      };
    };

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
}
