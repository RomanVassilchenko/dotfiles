{
  config,
  pkgs,
  lib,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  workEnable = vars.workEnable or false;
in
lib.mkIf workEnable {
  # Generate git config with secret email and GitLab hostname
  systemd.user.services.git-secrets-config-generator = {
    Unit = {
      Description = "Generate Git configuration with secrets";
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart =
        let
          script = pkgs.writeShellApplication {
            name = "generate-git-secrets";
            runtimeInputs = with pkgs; [ coreutils ];
            text = ''
              mkdir -p ~/.config/git

              # Wait for agenix secrets to be available (system service, so we poll)
              MAX_WAIT=60
              WAITED=0
              while [ ! -f /run/agenix/work-email ] && [ $WAITED -lt $MAX_WAIT ]; do
                sleep 1
                WAITED=$((WAITED + 1))
              done

              if [ ! -f /run/agenix/work-email ]; then
                echo "Timeout waiting for agenix secrets" >&2
                exit 1
              fi

              # Read secrets
              WORK_EMAIL=$(cat /run/agenix/work-email)
              GITLAB_HOSTNAME=$(cat /run/agenix/bereke-gitlab-hostname)

              # Generate git config with secrets
              cat > ~/.config/git/secrets << EOF
# Automatically generated from encrypted secrets
# Do not edit manually - changes will be overwritten

[user]
    email = $WORK_EMAIL

# URL remapping for GitLab SSH access
[url "ssh://git@$GITLAB_HOSTNAME/"]
    insteadOf = https://$GITLAB_HOSTNAME/

[url "git@$GITLAB_HOSTNAME:"]
    insteadOf = https://$GITLAB_HOSTNAME/

# SSL settings for company GitLab
[http "https://$GITLAB_HOSTNAME"]
    sslVerify = false
EOF

              chmod 600 ~/.config/git/secrets
            '';
          };
        in
        "${script}/bin/generate-git-secrets";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
