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

    # AMD GPU optimizations for integrated graphics (680M)
    boot.kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff" # Enable all power features
      "amdgpu.gpu_recovery=1" # Enable GPU recovery
      "amdgpu.dpm=1" # Dynamic Power Management
    ];

    # Mesa drivers optimization
    environment.variables = {
      # Enable AMD performance features
      AMD_VULKAN_ICD = "RADV";
      RADV_PERFTEST = "gpl,nggc"; # Enable graphics pipeline library and NGG culling
      # Force GPU acceleration for video decode
      VDPAU_DRIVER = "radeonsi";
      LIBVA_DRIVER_NAME = "radeonsi";
      # Mesa performance tweaks
      mesa_glthread = "true"; # Improve OpenGL multithreading
    };

    # Hardware video acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # AMD video acceleration
        libva-vdpau-driver
        libvdpau-va-gl
        rocmPackages.clr.icd
      ];
    };
  };
}
