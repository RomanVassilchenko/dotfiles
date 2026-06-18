{ inputs }:
{
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
}
