{
  isServer,
  username,
  ...
}:
{
  # Samba server for file sharing (server only)
  services.samba = {
    enable = isServer;
    openFirewall = isServer;

    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Ninkear NAS";
        "netbios name" = "ninkear";
        security = "user";
        "hosts allow" = "192.168.1. 100.64.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "Bad User";
        "server min protocol" = "SMB2";
      };

      # Backup share for dotfiles
      backup = {
        path = "/home/${username}/backup";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = username;
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = username;
        "force group" = "users";
      };
    };
  };

  # Enable Samba service discovery (wsdd) for Windows/Dolphin to find the share
  services.samba-wsdd = {
    enable = isServer;
    openFirewall = isServer;
  };
}
