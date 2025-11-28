{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/99cf7e8a-242f-4f43-bf63-aaa4c5161bb4";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4095-7A31";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/mnt/fedora" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = [
      "defaults"
      "user"
      "rw"
      "exec"
    ];
  };

  fileSystems."/mnt/Data" = {
    device = "/dev/nvme0n1p4";
    fsType = "btrfs";
    options = [
      "defaults"
      "user"
      "rw"
      "exec"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
