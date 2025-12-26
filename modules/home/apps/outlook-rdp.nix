{
  pkgs,
  lib,
  appConfig,
  ...
}:
let
  # RDP connection settings
  rdpHost = "172.24.98.91";
  rdpDomain = "SBERBANK";

  # Outlook path on remote Windows system (shortcut file)
  outlookPath = "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Outlook 2016.lnk";

  # FreeRDP wrapper script for Outlook
  outlook-rdp = pkgs.writeShellScriptBin "outlook-rdp" ''
    # Read credentials from agenix secrets
    RDP_USER=$(cat /run/agenix/rdp-outlook-username 2>/dev/null)
    RDP_PASS=$(cat /run/agenix/rdp-outlook-password 2>/dev/null)

    if [ -z "$RDP_USER" ] || [ -z "$RDP_PASS" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "Outlook RDP" "Failed to read credentials from agenix secrets"
      exit 1
    fi

    # Launch RDP with Outlook as shell program (auto-scales to screen)
    exec ${pkgs.freerdp}/bin/xfreerdp \
      /v:${rdpHost} \
      /d:${rdpDomain} \
      /u:"$RDP_USER" \
      /p:"$RDP_PASS" \
      /shell:"${outlookPath}" \
      /cert:ignore \
      /sec:tls \
      /dynamic-resolution \
      /gfx \
      /clipboard \
      /sound:sys:pulse \
      +compression \
      /workarea \
      /scale-desktop:125 \
      -grab-keyboard \
      "$@"
  '';
in
{
  home.packages = [
    outlook-rdp
    pkgs.freerdp
  ];

  # Desktop entry for Outlook
  xdg.desktopEntries.outlook-rdp = {
    name = "Outlook (RDP)";
    comment = "Microsoft Outlook via RDP";
    exec = "${outlook-rdp}/bin/outlook-rdp";
    icon = "ms-outlook";
    terminal = false;
    categories = [
      "Office"
      "Email"
      "Network"
    ];
    mimeType = [ "x-scheme-handler/mailto" ];
  };

  # Autostart Outlook on login (if enabled)
  xdg.configFile."autostart/outlook-rdp.desktop" = lib.mkIf appConfig.outlook-rdp.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Outlook (RDP)
      Comment=Microsoft Outlook via RDP
      Exec=${outlook-rdp}/bin/outlook-rdp
      Icon=ms-outlook
      Terminal=false
      Categories=Office;Email;Network;
      StartupWMClass=xfreerdp
    '';
  };
}
