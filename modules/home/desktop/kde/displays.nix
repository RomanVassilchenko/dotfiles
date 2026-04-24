{
  dotfiles,
  lib,
  pkgs,
  ...
}:
let
  setPrimaryDisplay = pkgs.writeShellScriptBin "kde-set-primary-display" ''
    set -eu

    KSCREEN="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
    SLEEP="${pkgs.coreutils}/bin/sleep"
    GREP="${pkgs.gnugrep}/bin/grep"

    # Wait for Plasma/KScreen to finish restoring outputs after login.
    "$SLEEP" 3
    outputs="$($KSCREEN -o 2>/dev/null || true)"

    if printf '%s\n' "$outputs" | "$GREP" -Eq 'Output: .* DP-9 .*connected'; then
      "$KSCREEN" output.DP-9.primary >/dev/null 2>&1 || true
    elif printf '%s\n' "$outputs" | "$GREP" -Eq 'Output: .* DP-8 .*connected'; then
      "$KSCREEN" output.DP-8.primary >/dev/null 2>&1 || true
    elif printf '%s\n' "$outputs" | "$GREP" -Eq 'Output: .* eDP-1 .*connected'; then
      "$KSCREEN" output.eDP-1.primary >/dev/null 2>&1 || true
    fi
  '';
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  home.packages = [ setPrimaryDisplay ];

  xdg.configFile."autostart/kde-set-primary-display.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Set Primary Display
    Comment=Prefer the horizontal external monitor as primary
    Exec=${setPrimaryDisplay}/bin/kde-set-primary-display
    Terminal=false
    X-KDE-autostart-phase=2
    NoDisplay=true
  '';
}
