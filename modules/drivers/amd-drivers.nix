{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.drivers.amdgpu;
in
{
  options.drivers.amdgpu = {
    enable = mkEnableOption "Enable AMD Drivers";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
    services.xserver.videoDrivers = [ "amdgpu" ];

    boot.kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
      "amdgpu.gpu_recovery=1"
      "amdgpu.dpm=1"
      "amd_pstate=active"
      "iommu=pt"
    ];

    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      RADV_PERFTEST = "gpl,nggc,sam";
      VDPAU_DRIVER = "radeonsi";
      LIBVA_DRIVER_NAME = "radeonsi";
      mesa_glthread = "true";
      MESA_SHADER_CACHE_MAX_SIZE = "5G";
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
        rocmPackages.clr.icd
      ];
    };
  };
}
