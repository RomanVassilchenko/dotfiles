{ lib, pkgs, ... }:
let
  sshConfig = pkgs.writeText "ssh-config" ''
    Include ~/.ssh/config.d/*

    Host *
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
