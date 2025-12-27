# Auto-upgrade - Automatic system updates for server
{ pkgs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "/home/romanv/backup/dotfiles#ninkear";
    flags = [ "--commit-lock-file" ];
    flakeUpdate.inputs = [ "nixpkgs" ];
    dates = "09:00:00";
    randomizedDelaySec = "5min";
    persistent = true;
    allowReboot = true;
    rebootWindow = {
      lower = "18:00";
      upper = "19:00";
    };
  };

  # Add git sync to the upgrade service
  systemd.services.nixos-upgrade = {
    path = [
      pkgs.git
      pkgs.openssh
    ];
    environment.HOME = "/root";
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "pre-upgrade-sync" ''
        cd /home/romanv/backup/dotfiles
        git config --global --add safe.directory /home/romanv/backup/dotfiles || true
        git fetch origin main
        git reset --hard origin/main
      '';
      ExecStartPost = pkgs.writeShellScript "post-upgrade-push" ''
        cd /home/romanv/backup/dotfiles
        git push origin main || true
      '';
    };
  };
}
