{ pkgs, ... }:
{
  # Docker for container management (podman disabled to avoid conflicts)
  virtualisation = {
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

    libvirtd = {
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

    # Enable common container config files
    containers.enable = true;
  };

  programs = {
    virt-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virt-viewer # View Virtual Machines
    lazydocker
    docker-client
  ];
}
