{
  inputs,
  host,
  config,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
in
{
  # Install agenix CLI tool
  environment.systemPackages = [
    inputs.agenix.packages.x86_64-linux.default
  ];

  # Configure agenix to use the host-specific SSH key for decryption
  age.identityPaths = [ vars.sshKeyPath ];

  # Work email address
  age.secrets.work-email = {
    file = ../../../secrets/work-email.age;
    mode = "440";
    owner = "romanv";
    group = "users";
  };

  # SSH configuration secrets
  age.secrets.ssh-host-home-ip = {
    file = ../../../secrets/ssh-host-home-ip.age;
    mode = "440";
    owner = "romanv";
    group = "users";
  };

  age.secrets.ssh-host-aq-ip = {
    file = ../../../secrets/ssh-host-aq-ip.age;
    mode = "440";
    owner = "romanv";
    group = "users";
  };

  age.secrets.bereke-gitlab-hostname = {
    file = ../../../secrets/bereke-gitlab-hostname.age;
    mode = "440";
    owner = "romanv";
    group = "users";
  };

  age.secrets.ssh-aq-username = {
    file = ../../../secrets/ssh-aq-username.age;
    mode = "440";
    owner = "romanv";
    group = "users";
  };
}
