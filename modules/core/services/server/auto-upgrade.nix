{ pkgs, ... }:
let
  dotfilesPath = "/home/romanv/backup/dotfiles";
  gitSafeDir = "-c safe.directory=${dotfilesPath}";
in
{
  system.autoUpgrade = {
    enable = true;
    flake = "${dotfilesPath}#ninkear";
    flags = [ ];
    dates = "09:00:00";
    randomizedDelaySec = "5min";
    persistent = true;
    allowReboot = true;
    rebootWindow = {
      lower = "18:00";
      upper = "19:00";
    };
  };

  systemd.services.nixos-upgrade = {
    path = [
      pkgs.git
      pkgs.openssh
      pkgs.tmux
      pkgs.curl
      pkgs.nix
    ];
    environment = {
      GIT_SSH_COMMAND = "ssh -i /home/romanv/.ssh/id_ed25519 -o StrictHostKeyChecking=no";
    };
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "pre-upgrade-sync" ''
        cd ${dotfilesPath}
        git ${gitSafeDir} fetch origin main
        git ${gitSafeDir} reset --hard origin/main

        # Update all flake inputs
        nix flake update ${dotfilesPath}

        # Re-pin nixpkgs to the latest commit the nixos-unstable channel has
        # certified (Hydra finished building it), so packages are available in
        # cache.nixos.org and won't be compiled from source.
        NIXPKGS_REV=$(${pkgs.curl}/bin/curl -sL https://channels.nixos.org/nixos-unstable/git-revision | tr -d '[:space:]')
        if [ -n "$NIXPKGS_REV" ]; then
          echo "Pinning nixpkgs to cached channel commit: $NIXPKGS_REV"
          nix flake lock ${dotfilesPath} --override-input nixpkgs "github:nixos/nixpkgs/$NIXPKGS_REV"
        else
          echo "WARNING: could not fetch cached nixpkgs revision, using updated HEAD"
        fi
      '';
      ExecStartPost = pkgs.writeShellScript "post-upgrade-push" ''
        cd ${dotfilesPath}
        git ${gitSafeDir} add flake.lock
        git ${gitSafeDir} diff --cached --quiet || git ${gitSafeDir} commit -m "chore: update flake inputs"
        git ${gitSafeDir} push origin main

        ${pkgs.tmux}/bin/tmux kill-session -t cache-build 2>/dev/null || true
        ${pkgs.tmux}/bin/tmux new-session -d -s cache-build \
          "cd ${dotfilesPath} && dot cache build 2>&1 | tee /tmp/cache-build.log; echo 'Build finished at $(date)' >> /tmp/cache-build.log"
      '';
    };
  };
}
