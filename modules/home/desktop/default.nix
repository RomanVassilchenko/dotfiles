{
  lib,
  isServer,
  ...
}:
{
  imports = lib.optionals (!isServer) [
    ./kde
    ./niri
  ];
}
