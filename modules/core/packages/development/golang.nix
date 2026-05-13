{
  config,
  lib,
  pkgs,
  ...
}:
let
  gci = pkgs.buildGoModule rec {
    pname = "gci";
    version = "0.14.0";

    src = pkgs.fetchFromGitHub {
      owner = "daixiang0";
      repo = "gci";
      rev = "v${version}";
      hash = "sha256-+qoHORHUMgr03v3RB+7+g9O/tlDkQKFmKybma0FdhVs=";
    };

    vendorHash = "sha256-MS6Ei58HpR/ueqdmGEx15WoSSSwDpQUcxAWz36UnhmA=";
    subPackages = [ "." ];
    excludedPackages = [ "v2" ];
  };
in
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = with pkgs; [
    delve
    gcc
    gci
    gnumake
    go
    go-task
    go-minimock
    go-mockery
    go-swag
    go-tools
    gofumpt
    golangci-lint-langserver
    golines
    goose
    gopls
    gotools
    gotestsum
    govulncheck
    mockgen
    oapi-codegen
    protoc-gen-connect-go
    sqlc
    air
    (golangci-lint.overrideAttrs (oldAttrs: rec {
      version = "1.64.8";
      src = fetchFromGitHub {
        owner = "golangci";
        repo = "golangci-lint";
        rev = "v${version}";
        hash = "sha256-H7IdXAleyzJeDFviISitAVDNJmiwrMysYcGm6vAoWso=";
      };
      vendorHash = "sha256-i7ec4U4xXmRvHbsDiuBjbQ0xP7xRuilky3gi+dT1H10=";
    }))

  ];
}
