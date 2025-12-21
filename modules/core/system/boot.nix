{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Custom NixOS Plymouth theme with Catppuccin colors
  nixos-plymouth-theme = pkgs.stdenv.mkDerivation {
    pname = "nixos-catppuccin-plymouth";
    version = "1.0.0";

    src = pkgs.writeTextDir "nixos-catppuccin-plymouth" "";

    buildInputs = [ pkgs.imagemagick ];

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/nixos-catppuccin

      # Create the theme file
      cat > $out/share/plymouth/themes/nixos-catppuccin/nixos-catppuccin.plymouth << 'EOF'
      [Plymouth Theme]
      Name=NixOS Catppuccin
      Description=NixOS boot splash with Catppuccin Mocha colors
      ModuleName=script

      [script]
      ImageDir=/share/plymouth/themes/nixos-catppuccin
      ScriptFile=/share/plymouth/themes/nixos-catppuccin/nixos-catppuccin.script
      EOF

      # Create larger NixOS logo (200x200)
      cat > $out/share/plymouth/themes/nixos-catppuccin/logo.svg << 'SVGEOF'
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
        <defs>
          <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#89b4fa;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#cba6f7;stop-opacity:1" />
          </linearGradient>
        </defs>
        <g transform="translate(100,100)">
          <!-- Lambda shape - NixOS logo -->
          <path d="M-60,-50 L-20,50 L0,10 L-40,-50 Z" fill="url(#grad)"/>
          <path d="M60,-50 L20,50 L0,10 L40,-50 Z" fill="url(#grad)"/>
          <path d="M-50,0 L50,0 L30,-40 L-30,-40 Z" fill="url(#grad)" transform="rotate(60)"/>
          <path d="M-50,0 L50,0 L30,-40 L-30,-40 Z" fill="url(#grad)" transform="rotate(-60)"/>
        </g>
      </svg>
      SVGEOF

      # Convert SVG to PNG
      ${pkgs.imagemagick}/bin/convert -background none -resize 200x200 \
        $out/share/plymouth/themes/nixos-catppuccin/logo.svg \
        $out/share/plymouth/themes/nixos-catppuccin/logo.png

      # Create the script
      cat > $out/share/plymouth/themes/nixos-catppuccin/nixos-catppuccin.script << 'SCRIPTEOF'
      # Catppuccin Mocha colors
      bg_color = Color(0.12, 0.12, 0.18);  # #1e1e2e (Base)
      fg_color = Color(0.80, 0.84, 0.96);  # #cdd6f4 (Text)
      accent_color = Color(0.80, 0.65, 0.97);  # #cba6f7 (Mauve)

      Window.SetBackgroundTopColor(bg_color.red, bg_color.green, bg_color.blue);
      Window.SetBackgroundBottomColor(bg_color.red, bg_color.green, bg_color.blue);

      # Logo - centered, in upper portion of screen
      logo.image = Image("logo.png");
      logo.sprite = Sprite(logo.image);
      logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
      logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2 - 80);  # 80px above center
      logo.sprite.SetOpacity(1);

      # Progress bar settings
      progress_box.image = Image.Box(400, 8, fg_color.red, fg_color.green, fg_color.blue);
      progress_box.sprite = Sprite(progress_box.image);
      progress_box.sprite.SetX(Window.GetWidth() / 2 - 200);
      progress_box.sprite.SetY(Window.GetHeight() / 2 + 100);  # 100px below center (padding)
      progress_box.sprite.SetOpacity(0.3);

      progress_bar.original_image = Image.Box(400, 8, accent_color.red, accent_color.green, accent_color.blue);
      progress_bar.sprite = Sprite();
      progress_bar.sprite.SetX(Window.GetWidth() / 2 - 200);
      progress_bar.sprite.SetY(Window.GetHeight() / 2 + 100);

      fun refresh_callback() {
        # Just keep things running smoothly
      }

      Plymouth.SetRefreshFunction(refresh_callback);

      # Progress callback
      fun boot_progress_callback(duration, progress) {
        if (progress > 1) progress = 1;
        if (progress < 0) progress = 0;

        new_width = progress * 400;
        if (new_width > 0) {
          progress_bar.image = progress_bar.original_image.Scale(new_width, 8);
          progress_bar.sprite.SetImage(progress_bar.image);
        }
      }

      Plymouth.SetBootProgressFunction(boot_progress_callback);

      # Message handling (hide messages for clean boot)
      fun message_callback(text) {
        # Don't display messages
      }

      Plymouth.SetMessageFunction(message_callback);

      # Hide password prompt styling (if needed)
      fun display_password_callback(prompt, bullets) {
        # Minimal password display
      }

      Plymouth.SetDisplayPasswordFunction(display_password_callback);

      # Quit callback
      fun quit_callback() {
      }

      Plymouth.SetQuitFunction(quit_callback);
      SCRIPTEOF
    '';
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

    # Silent boot - no terminal output
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;

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

    # Plymouth boot splash with custom NixOS Catppuccin theme
    plymouth = {
      enable = true;
      theme = lib.mkForce "nixos-catppuccin";
      themePackages = [ nixos-plymouth-theme ];
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
