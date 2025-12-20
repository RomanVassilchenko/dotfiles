{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Include sensitive hosts from generated config file
    includes = [ "~/.ssh/config.d/secrets" ];

    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_personal";
        identitiesOnly = true;
      };

      "ssh.romanv.dev" = {
        user = "romanv";
        identityFile = "~/.ssh/id_personal";
        extraOptions = {
          ProxyCommand = "cloudflared access ssh --hostname %h";
        };
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
        # Manually specify commonly useful SSH defaults
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
          # Post-quantum key exchange algorithms (hybrid mode)
          # Protects against "store now, decrypt later" attacks
          # Format: <post-quantum>@<classical> provides quantum-safe + backwards compatible security
          # mlkem768x25519-sha256: NIST ML-KEM-768 + X25519 (FIPS-approved, recommended)
          # sntrup761x25519-sha512: Streamlined NTRU Prime + X25519 (older alternative)
          # Falls back to classical algorithms if server doesn't support PQ
          KexAlgorithms = "mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
        };
      };
    };
  };
}
