{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot = {
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera" video_nr=9
    '';

    kernelParams = [
      "quiet"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "preempt=voluntary"
      "nowatchdog"
      "psi=1"
      "splash"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;

    plymouth = {
      enable = true;
      theme = lib.mkForce "catppuccin-macchiato";
      themePackages = [ pkgs.catppuccin-plymouth ];
    };

    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  programs.xwayland.enable = true;
}
