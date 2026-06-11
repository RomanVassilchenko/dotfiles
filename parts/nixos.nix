{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  publicHostsDir = ../hosts;
  privateHostsDir = ../private/hosts;
  hostDefaults = import ../hosts/default/common.nix;
  freerdpRdpCamOverlay = import ../lib/overlays/freerdp-rdpecam.nix;

  mkStable =
    system:
    import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

  mkBitwarden =
    system:
    import inputs.nixpkgs-bitwarden {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-39.8.10" ];
      };
    };

  gpuConfig = {
    intel = {
      drivers.intel.enable = true;
    };
    amd = {
      drivers.amdgpu.enable = true;
    };
  };

  hostDirs = [ publicHostsDir ] ++ lib.optional (builtins.pathExists privateHostsDir) privateHostsDir;

  hostNames =
    let
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
    in
    lib.unique (
      (namesFrom publicHostsDir true)
      ++ (if builtins.pathExists privateHostsDir then namesFrom privateHostsDir false else [ ])
    );

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
        pkgs-bitwarden = mkBitwarden system;
        pkgs-stable = mkStable system;
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
        ../modules/drivers/amd-drivers.nix
        ../modules/drivers/intel-drivers.nix
        ../modules/core/desktop/fonts.nix
        ../modules/core/desktop/plasma.nix
        ../modules/core/desktop/stylix.nix
        ../modules/core/packages/cli/containers.nix
        ../modules/core/packages/cli/core.nix
        ../modules/core/packages/cli/fetch.nix
        ../modules/core/packages/cli/media.nix
        ../modules/core/packages/cli/modern.nix
        ../modules/core/packages/cli/network.nix
        ../modules/core/packages/cli/nix.nix
        ../modules/core/packages/cli/system.nix
        ../modules/core/packages/development/ai.nix
        ../modules/core/packages/development/core.nix
        ../modules/core/packages/development/databases.nix
        ../modules/core/packages/development/golang.nix
        ../modules/core/packages/development/java.nix
        ../modules/core/packages/development/node.nix
        ../modules/core/packages/development/protobuf.nix
        ../modules/core/packages/development/python.nix
        ../modules/core/packages/development/research.nix
        ../modules/core/packages/desktop/apps.nix
        ../modules/core/packages/desktop/browsers.nix
        ../modules/core/packages/desktop/communication.nix
        ../modules/core/packages/desktop/creative.nix
        ../modules/core/packages/desktop/devtools.nix
        ../modules/core/packages/desktop/gaming.nix
        ../modules/core/packages/desktop/productivity.nix
        ../modules/core/services/common.nix
        ../modules/core/services/desktop.nix
        ../modules/core/services/flatpak.nix
        ../modules/core/services/firewall.nix
        ../modules/core/services/kdeconnect.nix
        ../modules/core/services/logiops.nix
        ../modules/core/services/performance.nix
        ../modules/core/services/printing.nix
        ../modules/core/services/server/atuin.nix
        ../modules/core/services/server/samba.nix
        ../modules/core/services/server/t3code.nix
        ../modules/core/services/server/vaultwarden.nix
        ../modules/core/system/dotfiles.nix
        ../modules/core/system/boot.nix
        ../modules/core/system/hardware.nix
        ../modules/core/system/local-hardware-clock.nix
        ../modules/core/system/network.nix
        ../modules/core/system/security.nix
        ../modules/core/system/system.nix
        ../modules/core/system/thermal.nix
        ../modules/core/system/user.nix
        ../modules/core/system/virtualisation.nix
        ../modules/core/system/boot-desktop.nix
        ../modules/core/tools/nh.nix
        ../modules/core/tools/packages.nix
      ]
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
      apps.dot = {
        type = "app";
        program = "${dotCli}/bin/dot";
        meta.description = "Manage and rebuild these NixOS dotfiles";
      };
    };

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
}
