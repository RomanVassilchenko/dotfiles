{
  description = "Dotfiles";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      plasma-manager,
      agenix,
      ...
    }@inputs:
    let
      username = "romanv";

      # Helper to build host-specific configurations
      mkNixosConfig =
        { gpuProfile, host }:
        let
          vars = import ./hosts/${host}/variables.nix;
          deviceType = vars.deviceType or "laptop";
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
              ;
            profile = gpuProfile;
          };
          modules = [
            ./profiles/${gpuProfile}
            nix-flatpak.nixosModules.nix-flatpak
            agenix.nixosModules.default
            inputs.stylix.nixosModules.stylix
          ];
        };
    in
    {
      nixosConfigurations = {
        laptop-82sn = mkNixosConfig {
          gpuProfile = "amd";
          host = "laptop-82sn";
        };
        probook-450 = mkNixosConfig {
          gpuProfile = "intel";
          host = "probook-450";
        };
        ninkear = mkNixosConfig {
          gpuProfile = "amd";
          host = "ninkear";
        };
      };
    };
}
