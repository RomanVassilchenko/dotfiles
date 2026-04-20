_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [ "~/.ssh/config.d/secrets" ];

    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_personal";
        identitiesOnly = true;
      };

      # Forgejo git server (SSH on port 2222 via Tailscale)
      # NixOS Forgejo uses 'forgejo' as SSH user, not 'git'
      "git.romanv.dev" = {
        hostname = "100.64.0.1";
        port = 2222;
        user = "forgejo";
        identityFile = "~/.ssh/id_personal";
        identitiesOnly = true;
      };

      # Ninkear via Tailscale P2P (direct connection, no tunnel)
      "ninkear" = {
        hostname = "100.64.0.1";
        user = "romanv";
        identityFile = "~/.ssh/id_personal";
      };

      "*" = {
        identityFile = "~/.ssh/id_personal";
        identitiesOnly = true;
        forwardAgent = false;
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        addKeysToAgent = "no";

        extraOptions = {
          KexAlgorithms = "mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
        };
      };
    };
  };
}
