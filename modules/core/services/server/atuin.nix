{ ... }:
{
  services.atuin = {
    enable = true;
    host = "0.0.0.0";
    port = 8888;
    openRegistration = true;
    openFirewall = true;
    maxHistoryLength = 8192;
    database.createLocally = true;
  };
}
