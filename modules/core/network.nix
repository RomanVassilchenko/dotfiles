{ host, ... }:
{
  networking = {
    hostName = "${host}";
  };
}
