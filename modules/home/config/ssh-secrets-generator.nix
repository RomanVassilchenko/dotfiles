{ config, pkgs, ... }:
{
  # Generate SSH config with secrets
  systemd.user.services.ssh-secrets-config-generator = {
    Unit = {
      Description = "Generate SSH configuration with secrets";
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "generate-ssh-secrets" ''
        mkdir -p ~/.ssh/config.d

        # Wait for agenix secrets to be available (system service, so we poll)
        MAX_WAIT=60
        WAITED=0
        while [ ! -f /run/agenix/bereke-gitlab-hostname ] && [ $WAITED -lt $MAX_WAIT ]; do
          sleep 1
          WAITED=$((WAITED + 1))
        done

        if [ ! -f /run/agenix/bereke-gitlab-hostname ]; then
          echo "Timeout waiting for agenix secrets" >&2
          exit 1
        fi

        # Read secrets
        GITLAB_HOSTNAME=$(cat /run/agenix/bereke-gitlab-hostname)
        HOME_IP=$(cat /run/agenix/ssh-host-home-ip)
        AQ_IP=$(cat /run/agenix/ssh-host-aq-ip)
        AQ_USERNAME=$(cat /run/agenix/ssh-aq-username)

        # Generate SSH config for sensitive hosts
        cat > ~/.ssh/config.d/secrets << EOF
# Automatically generated from encrypted secrets
# Do not edit manually - changes will be overwritten

Host $GITLAB_HOSTNAME
    IdentityFile ~/.ssh/id_xiaoxinpro_work
    PreferredAuthentications publickey

Host $HOME_IP
    IdentityFile ~/.ssh/id_personal
    PreferredAuthentications publickey

Host aq
    HostName $AQ_IP
    User $AQ_USERNAME
    IdentityFile ~/.ssh/id_personal
    PreferredAuthentications publickey
EOF

        chmod 600 ~/.ssh/config.d/secrets
      '';
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
