{
  host = {
    system = "x86_64-linux";
    profile = "workstation";
  };

  user = {
    name = "youruser";
    gitName = "Your Name";
    gitEmail = null;
    authorizedKeys = [ ];
  };

  locale = {
    keyboardLayout = "us";
    consoleKeyMap = "us";
    timeZone = "UTC";
    defaultLocale = "en_US.UTF-8";
  };

  paths = { };
}
