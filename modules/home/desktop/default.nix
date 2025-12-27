# Desktop environment configuration - desktop only
{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./kde
  ];
}
