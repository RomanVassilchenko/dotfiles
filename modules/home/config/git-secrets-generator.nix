{ config, pkgs, ... }:
{
  # Generate git config with secret email and GitLab hostname
  systemd.user.services.git-secrets-config-generator = {
    Unit = {
      Description = "Generate Git configuration with secrets";
      After = [ "agenix.service" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "generate-git-secrets" ''
                mkdir -p ~/.config/git

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

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
