{ pkgs, lib, config, ... }:

let
  # Catppuccin Plymouth theme
  catppuccin-plymouth = pkgs.catppuccin-plymouth.override {
    variant = "mocha";
  };
in
{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera" video_nr=9
    '';
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    # Plymouth boot splash with Catppuccin Mocha theme
    plymouth = {
      enable = true;
      theme = lib.mkForce "catppuccin-mocha";
      themePackages = [ catppuccin-plymouth ];
    };
  };

  # Disable systemd services that are affecting the boot time
  systemd.services = {
    NetworkManager-wait-online.enable = false;
    plymouth-quit-wait.enable = false;
  };

  # Enable devmon for device management
  services.devmon.enable = true;

  # Enable xwayland
  programs.xwayland.enable = true;

  # Additional services
  services.locate.enable = true;
}
