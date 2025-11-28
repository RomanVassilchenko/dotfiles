{
  pkgs,
  pkgs-pinned,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Go Language and Core Tools
    go # Go Programming Language
    gopls # Go language server
    gotools # Go development tools (goimports, etc.)
    go-tools # Additional Go tools

    # Go Formatters and Linters
    golines # Go line length formatter
    (pkgs-pinned.golangci-lint.overrideAttrs (oldAttrs: rec {
      version = "1.64.8";
      src = pkgs-pinned.fetchFromGitHub {
        owner = "golangci";
        repo = "golangci-lint";
        rev = "v${version}";
        hash = "sha256-H7IdXAleyzJeDFviISitAVDNJmiwrMysYcGm6vAoWso=";
      };
      vendorHash = "sha256-i7ec4U4xXmRvHbsDiuBjbQ0xP7xRuilky3gi+dT1H10=";
    }))

    # Go Testing and Mocking
    go-minimock # Go mock generator from interfaces
    mockgen # Go mock generator

    # Go Debugging
    delve # Go debugger

    # Go Database Tools
    goose # Database migration tool

    # Go Build Tools
    statik # Go static file embedding

    # CGO Support (required for some Go packages)
    gcc # C compiler for CGO support
    gnumake # GNU Make build tool
  ];
}
