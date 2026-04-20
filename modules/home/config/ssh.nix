{ lib, pkgs, ... }:
let
  sshConfig = pkgs.writeText "ssh-config" ''
    Include ~/.ssh/config.d/secrets

    Host github.com
      IdentityFile ~/.ssh/id_personal
      IdentitiesOnly yes

    # Forgejo git server (SSH on port 2222 via Tailscale)
    # NixOS Forgejo uses 'forgejo' as SSH user, not 'git'
    Host git.romanv.dev
      HostName 100.64.0.1
      Port 2222
      User forgejo
      IdentityFile ~/.ssh/id_personal
      IdentitiesOnly yes

    # Ninkear via Tailscale P2P (direct connection, no tunnel)
    Host ninkear
      HostName 100.64.0.1
      User romanv
      IdentityFile ~/.ssh/id_personal

    Host *
      IdentityFile ~/.ssh/id_personal
      IdentitiesOnly yes
      ForwardAgent no
      Compression no
      ServerAliveInterval 0
      ServerAliveCountMax 3
      HashKnownHosts no
      UserKnownHostsFile ~/.ssh/known_hosts
      ControlMaster no
      ControlPath ~/.ssh/master-%r@%n:%p
      ControlPersist no
      AddKeysToAgent no
      KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
  '';
in
{
  # Some Git/IDE integrations reject ~/.ssh/config when Home Manager manages it as a symlink into /nix/store.
  home.activation.installSshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.coreutils}/bin/install -d -m 700 "$HOME/.ssh"
    ${pkgs.coreutils}/bin/install -m 600 ${sshConfig} "$HOME/.ssh/config"
  '';
}
