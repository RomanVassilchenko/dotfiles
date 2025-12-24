{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    delta
    act
    nodejs
    playwright-driver.browsers
    jdk
    pkg-config

    # Formatters
    nixfmt-rfc-style
    nodePackages.prettier
    shfmt

    postman

    # OpenAPI code generator (custom build for specific version)
    (buildGoModule rec {
      pname = "oapi-codegen";
      version = "2.2.0";
      src = fetchFromGitHub {
        owner = "deepmap";
        repo = "oapi-codegen";
        rev = "v${version}";
        hash = "sha256-xeOIFznz1brHw9haLNV7b2A4oNOdVUKMQUM2dF979QU=";
      };
      vendorHash = "sha256-urPMLEaisgndbHmS1sGQ07c+VRBdxIz0wseLoSLVWQo=";
      subPackages = [ "cmd/oapi-codegen" ];
      doCheck = false;
      ldflags = [
        "-s"
        "-w"
        "-X main.noVCSVersionOverride=v${version}"
      ];
      meta = with lib; {
        description = "Generate Go client and server boilerplate from OpenAPI 3 specifications";
        homepage = "https://github.com/deepmap/oapi-codegen";
        license = licenses.asl20;
        mainProgram = "oapi-codegen";
      };
    })
  ];
}
