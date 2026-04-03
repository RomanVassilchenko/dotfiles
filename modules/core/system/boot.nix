{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot =
    let
      hostIsServer = config.dotfiles.host.isServer;
    in
    {
      kernelPackages = pkgs.linuxPackages_latest;

      kernelParams = [
        "randomize_kstack_offset=on"
        "vsyscall=none"
        "slab_nomerge"
        "page_poison=1"
        "page_alloc.shuffle=1"
        "init_on_alloc=1"
        "init_on_free=1"
      ];

      kernel.sysctl = {
        "vm.max_map_count" = 2147483642;
        "vm.swappiness" = 10;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.vfs_cache_pressure" = 50;
        "kernel.nmi_watchdog" = 0;
        # network performance
        "net.core.netdev_budget" = 600;
        "net.core.netdev_max_backlog" = 16384;
        "net.ipv4.tcp_no_metrics_save" = 1;
        "net.ipv4.tcp_moderate_rcvbuf" = 1;
        # TCP hardening
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_rfc1337" = 1;
        # TCP optimization (BBR + CAKE)
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.ip_forward" = 1;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
        # network buffers
        "net.core.rmem_default" = 262144;
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_default" = 262144;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 131072 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";
        "net.ipv4.tcp_window_scaling" = 1;
        "net.ipv4.tcp_timestamps" = 1;
        "net.ipv4.tcp_sack" = 1;
        "net.ipv4.tcp_adv_win_scale" = 1;
        "net.ipv4.tcp_fin_timeout" = 15;
        "net.ipv4.tcp_tw_reuse" = 1;
        # security hardening
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "net.core.bpf_jit_harden" = 2;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;
        "fs.suid_dumpable" = 0;
        "kernel.randomize_va_space" = 2;
        "kernel.core_uses_pid" = 1;
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;
        "dev.tty.ldisc_autoload" = 0;
        "vm.unprivileged_userfaultfd" = 0;
      };

      kernelModules = [ "tcp_bbr" ];

      blacklistedKernelModules = [
        "firewire-core"
        "thunderbolt"
        "dccp"
        "sctp"
        "rds"
        "tipc"
      ];

      tmp = {
        useTmpfs = true;
        cleanOnBoot = true;
      };

      loader.systemd-boot.enable = if hostIsServer then true else lib.mkForce false;
      loader.efi.canTouchEfiVariables = true;
      loader.timeout = 1;

      lanzaboote = {
        enable = !hostIsServer;
        pkiBundle = "/var/lib/sbctl";
      };
    };

  services.devmon.enable = true;

  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "daily";
    prunePaths = [
      "/tmp"
      "/var/tmp"
      "/var/cache"
      "/var/lock"
      "/var/run"
      "/var/spool"
      "/nix/store"
      "/nix/var/nix/db"
    ];
  };
}
