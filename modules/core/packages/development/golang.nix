{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Go Language and Core Tools
    go
    gopls
    gotools
    go-tools

    # Go Formatters and Linters
    golines
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

    # Go Testing and Mocking
    go-minimock
    mockgen

    # Go Debugging
    delve

    # Go Database Tools
    goose

    # Go Build Tools
    statik

    # CGO Support (required for some Go packages)
    gcc
    gnumake
  ];
}
