{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  config = lib.mkIf isServer {
    # Harmonia binary cache server
    services.harmonia = {
      enable = true;
      signKeyPaths = [ "/var/lib/harmonia/secret-key" ];
      settings = {
        bind = "0.0.0.0:5000";
        workers = 4;
        max_connection_rate = 256;
        priority = 50;
      };
    };

    # Open firewall for harmonia
    networking.firewall.allowedTCPPorts = [ 5000 ];

    # Ensure harmonia key directory exists
    systemd.tmpfiles.rules = [
      "d /var/lib/harmonia 0750 root root -"
    ];

    # Generate signing key if it doesn't exist
    systemd.services.harmonia-key-init = {
      description = "Initialize Harmonia signing key";
      wantedBy = [ "harmonia.service" ];
      before = [ "harmonia.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ ! -f /var/lib/harmonia/secret-key ]; then
          ${pkgs.nix}/bin/nix-store --generate-binary-cache-key ninkear-cache /var/lib/harmonia/secret-key /var/lib/harmonia/public-key
          chmod 600 /var/lib/harmonia/secret-key
          chmod 644 /var/lib/harmonia/public-key
          echo "Harmonia signing key generated. Public key:"
          cat /var/lib/harmonia/public-key
        fi
      '';
    };

    # Configure nix to sign all builds for the cache
    nix.settings = {
      secret-key-files = [ "/var/lib/harmonia/secret-key" ];
    };

    # Disable automatic GC - handled by weekly-cleanup service
    # This avoids conflict with nh.clean
    nix.gc.automatic = lib.mkForce false;

    # Keep last 3 system generations
    boot.loader.systemd-boot.configurationLimit = 3;
  };
}
