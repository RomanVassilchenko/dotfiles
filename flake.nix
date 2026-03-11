{
  description = "Dotfiles";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    {
      self,
      nixpkgs,
      llm-agents,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      username = "romanv";

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
          vars = nixpkgs.lib.recursiveUpdate (commonDefaults // profileDefaults) hostVars;
          deviceType = vars.deviceType or (if profile == "server" then "server" else "laptop");
          isServer = deviceType == "server";
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              username
              host
              vars
              isServer
              profile
              ;
          };
          modules = [
            { nixpkgs.overlays = [ llm-agents.overlays.default ]; }
            ./hosts/${host}
            ./modules/drivers
            ./modules/core
            gpuConfig.${gpuProfile}
            inputs.stylix.nixosModules.stylix
            inputs.nix-flatpak.nixosModules.nix-flatpak
          ]
          ++ lib.optional (builtins.pathExists ./private/default.nix) ./private;
        };
    in
    {
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

      checks.x86_64-linux = {
        laptop-82sn = self.nixosConfigurations.laptop-82sn.config.system.build.toplevel;
        ninkear = self.nixosConfigurations.ninkear.config.system.build.toplevel;
      };
    };
}
