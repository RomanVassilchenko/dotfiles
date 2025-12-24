{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    buf
    (protobuf_29.overrideAttrs (oldAttrs: rec {
      version = "29.3";
      src = fetchFromGitHub {
        owner = "protocolbuffers";
        repo = "protobuf";
        rev = "v${version}";
        hash = "sha256-zdOBzLdN0ySrdFTF/X/NYI57kJ1ZFyoIl1/Qtgh/VkI=";
      };
    }))
    (protoc-gen-go.overrideAttrs (oldAttrs: rec {
      version = "1.36.3";
      src = fetchFromGitHub {
        owner = "protocolbuffers";
        repo = "protobuf-go";
        rev = "v${version}";
        hash = "sha256-yzrdZMWl5MBOAGCXP1VxVZNLCSFUWEURVYiDhRKSSRc=";
      };
      vendorHash = "sha256-nGI/Bd6eMEoY0sBwWEtyhFowHVvwLKjbT4yfzFz6Z3E=";
    }))
    (protoc-gen-go-grpc.overrideAttrs (oldAttrs: rec {
      version = "1.5.1";
      src = fetchFromGitHub {
        owner = "grpc";
        repo = "grpc-go";
        rev = "cmd/protoc-gen-go-grpc/v${version}";
        hash = "sha256-PAUM0chkZCb4hGDQtCgHF3omPm0jP1sSDolx4EuOwXo=";
      };
      vendorHash = "sha256-yn6jo6Ku/bnbSX8FL0B/Uu3Knn59r1arjhsVUkZ0m9g=";
    }))
    protoc-gen-doc
    protoc-gen-go-vtproto
    protoc-gen-validate
    gnostic
    grpc-gateway
    protolint
  ];
}
