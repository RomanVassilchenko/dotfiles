# Virtualisation - Docker and container support
# Available on all systems
{ pkgs, lib, isServer, ... }:
{
  virtualisation = {
    # Docker for container management
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    # Podman disabled - using Docker instead
    podman.enable = false;

    # Enable common container config files
    containers.enable = true;

    # Libvirt - desktop only (VMs)
    libvirtd = lib.mkIf (!isServer) {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true; # TPM emulation for Windows 11
      };
    };

    virtualbox.host = {
      enable = false;
      enableExtensionPack = true;
    };
  };

  # Virt-manager - desktop only
  programs.virt-manager.enable = !isServer;

  environment.systemPackages =
    with pkgs;
    [
      lazydocker
      docker-client
    ]
    ++ lib.optionals (!isServer) [
      virt-viewer # View Virtual Machines - desktop only
    ];
}
