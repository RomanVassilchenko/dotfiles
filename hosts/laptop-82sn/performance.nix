{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Performance optimizations specific to laptop-82sn (AMD Ryzen 6800H + Radeon 680M)

  # Zram - compressed swap in RAM for better performance
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Fast compression
    memoryPercent = 50; # Use 50% of RAM for zram
  };

  # CPU governor for better performance/battery balance
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil"; # Dynamic CPU frequency scaling
  };

  # Kernel parameters for performance
  boot.kernel.sysctl = {
    # Improve responsiveness
    "vm.swappiness" = 10; # Prefer RAM over swap
    "vm.vfs_cache_pressure" = 50; # Keep directory/inode cache

    # Network performance
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.core.rmem_default" = 1048576;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 1048576;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_fastopen" = 3;

    # Reduce latency
    "kernel.sched_latency_ns" = 4000000; # 4ms
    "kernel.sched_min_granularity_ns" = 500000; # 0.5ms
  };

  # Enable fstrim for SSD optimization
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Hardware video acceleration for all applications
  environment.sessionVariables = {
    # Force hardware video acceleration
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";

    # Chromium/Brave/Electron apps hardware acceleration
    NIXOS_OZONE_WL = "1"; # Enable Wayland with hardware acceleration
  };

  # System optimization packages
  environment.systemPackages = with pkgs; [
    htop # Process viewer
    iotop # I/O monitor
    lm_sensors # Hardware monitoring
    libva-utils # VA-API utilities (vainfo command)
    vdpauinfo # VDPAU utilities
  ];
}
