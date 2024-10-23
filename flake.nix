{
  description = "NixOS and macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";

    nix-gaming.url = "github:fufexan/nix-gaming";

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprmag.url = "github:SIMULATAN/hyprmag";

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      nixpkgs,
      self,
      nix-darwin,
      home-manager,
      nix-flatpak,
      plasma-manager,
      ...
    }@inputs:
    let
      username = "rovasilchenko";

      nixosSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      pkgsLinux = import nixpkgs {
        system = nixosSystem;
        config.allowUnfree = true;
      };

      pkgsDarwin = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
      };

      libLinux = pkgsLinux.lib;
      libDarwin = pkgsDarwin.lib;
    in
    {
      nixosConfigurations = {
        XiaoXinPro = pkgsLinux.lib.nixosSystem {
          inherit nixosSystem;
          modules = [ ./hosts/XiaoXinPro ];
          specialArgs = {
            host = "XiaoXinPro";
            inherit self inputs username;
          };
        };
      };

      darwinConfigurations = {
        mbp-rovasilchenko-OZON-W0HDJTC2M5 = nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          modules = [
            (
              { pkgs, ... }:
              {
                system.configurationRevision = self.rev or "unknown-rev";
              }
            )
            ./hosts/mbp-rovasilchenko-OZON-W0HDJTC2M5
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rovasilchenko = import ./modules/home/default.darwin.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
          specialArgs = {
            host = "mbp-rovasilchenko-OZON-W0HDJTC2M5";
            inherit self inputs username;
          };
        };
      };
    };
}
