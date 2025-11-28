{ config, pkgs, ... }:
{
  # Generate SSH config with secrets
  systemd.user.services.ssh-secrets-config-generator = {
    Unit = {
      Description = "Generate SSH configuration with secrets";
      After = [ "agenix.service" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "generate-ssh-secrets" ''
                mkdir -p ~/.ssh/config.d

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
