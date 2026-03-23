{
  pkgs,
  pkgs-stable,
  lib,
  isServer,
  ...
}:
{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    containers.enable = true;

    libvirtd = lib.mkIf isServer {
      enable = true;
      qemu = {
        package = pkgs-stable.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };

  programs.virt-manager.enable = isServer;

  systemd.services.virt-secret-init-encryption = lib.mkIf isServer {
    before = [
      "virtsecretd.service"
      "libvirtd.service"
    ];
    unitConfig.ConditionPathExists = "!/var/lib/libvirt/secrets/secrets-encryption-key";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        ""
        "${pkgs.bash}/bin/bash -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
      ];
    };
  };

  environment.systemPackages = [
    pkgs-stable.lazydocker
  ]
  ++ lib.optionals isServer [ pkgs-stable.virt-viewer ];
}
