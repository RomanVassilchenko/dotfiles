{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5e5b42af-fa40-4bce-9b77-582deb0bfd1b";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/5e5b42af-fa40-4bce-9b77-582deb0bfd1b";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F4B2-DBCD";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/mnt/Games" = {
      device = "/dev/disk/by-uuid/e7bee89b-3c2c-42f8-916e-16a2a142974d";
      fsType = "btrfs";
      options = [
        "nofail"
        "x-systemd.automount"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/Games 0775 romanv users -"
  ];

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/9b4bef6f-b4b0-4442-b69d-e43ae50b39e2";
      discardPolicy = "both";
    }
  ];

  # Required for hibernation to work
  boot.resumeDevice = "/dev/disk/by-uuid/9b4bef6f-b4b0-4442-b69d-e43ae50b39e2";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
