{
  inputs,
  lib,
  host,
  config,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  workEnable = vars.workEnable or false;
in
{
  # Install agenix CLI tool
  environment.systemPackages = [
    inputs.agenix.packages.x86_64-linux.default
  ];

  # Configure agenix to use the host-specific SSH key for decryption
  age.identityPaths = [ vars.sshKeyPath ];

  # Work-related secrets (only enabled when workEnable is true)
  age.secrets = lib.mkIf workEnable {
    # Work email address
    work-email = {
      file = ../../../secrets/work-email.age;
      mode = "440";
      owner = "romanv";
      group = "users";
    };

    # SSH configuration secrets
    ssh-host-home-ip = {
      file = ../../../secrets/ssh-host-home-ip.age;
      mode = "440";
      owner = "romanv";
      group = "users";
    };

    ssh-host-aq-ip = {
      file = ../../../secrets/ssh-host-aq-ip.age;
      mode = "440";
      owner = "romanv";
      group = "users";
    };

    bereke-gitlab-hostname = {
      file = ../../../secrets/bereke-gitlab-hostname.age;
      mode = "440";
      owner = "romanv";
      group = "users";
    };

    ssh-aq-username = {
      file = ../../../secrets/ssh-aq-username.age;
      mode = "440";
      owner = "romanv";
      group = "users";
    };
  };
}
