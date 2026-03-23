{
  description = "Dotfiles";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Stable channel — change version here to switch (e.g. "nixos-25.05", "nixos-26.05")
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      {
        systems = [ "x86_64-linux" ];

        imports = [
          ./modules/wrappedPrograms/noctalia.nix
        ];

        flake =
          let
            inherit (inputs.nixpkgs) lib;
            username = "romanv";

            mkStable =
              system:
              import inputs.nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };

            gpuConfig = {
              intel = {
                drivers.intel.enable = true;
              };
              amd = {
                drivers.amdgpu.enable = true;
              };
            };

            mkNixosConfig =
              {
                gpuProfile,
                host,
                profile,
              }:
              let
                commonDefaults = import ./hosts/default/common.nix;
                hostVars = import ./hosts/${host}/variables.nix;
                profileDefaults = import ./hosts/profiles/${profile}.nix;
                vars = lib.recursiveUpdate (commonDefaults // profileDefaults) hostVars;
                deviceType = vars.deviceType or (if profile == "server" then "server" else "laptop");
                isServer = deviceType == "server";
              in
              inputs.nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = {
                  inherit
                    inputs
                    self
                    username
                    host
                    vars
                    isServer
                    profile
                    ;
                  pkgs-stable = mkStable "x86_64-linux";
                };
                modules = [
                  {
                    nixpkgs.overlays = [
                      inputs.llm-agents.overlays.default
                      (final: prev: {
                        # Enable MS-RDPECAM camera redirection (V4L2 backend)
                        freerdp = prev.freerdp.overrideAttrs (old: {
                          buildInputs = old.buildInputs ++ [ final.linuxHeaders ];
                          cmakeFlags = old.cmakeFlags ++ [ "-DCHANNEL_RDPECAM_CLIENT:BOOL=ON" ];
                        });
                      })
                    ];
                  }
                  ./hosts/${host}
                  ./modules/drivers
                  ./modules/core
                  gpuConfig.${gpuProfile}
                  inputs.stylix.nixosModules.stylix
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                  inputs.lanzaboote.nixosModules.lanzaboote
                ]
                ++ lib.optional (builtins.pathExists ./private/default.nix) ./private;
              };

            nixosConfigurations = {
              laptop-82sn = mkNixosConfig {
                gpuProfile = "amd";
                host = "laptop-82sn";
                profile = "workstation";
              };
              ninkear = mkNixosConfig {
                gpuProfile = "amd";
                host = "ninkear";
                profile = "server";
              };
            };
          in
          {
            inherit nixosConfigurations;
            checks.x86_64-linux = {
              laptop-82sn = nixosConfigurations.laptop-82sn.config.system.build.toplevel;
              ninkear = nixosConfigurations.ninkear.config.system.build.toplevel;
            };
          };
      }
    );
}
