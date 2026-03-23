{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    buf
    gnostic
    grpc-gateway
    protobuf
    protoc-gen-doc
    protoc-gen-go
    protoc-gen-go-grpc
    protoc-gen-go-vtproto
    protoc-gen-validate
    protolint
  ];
}
