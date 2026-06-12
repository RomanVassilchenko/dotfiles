{
  config,
  lib,
  pkgs,
  pkgs-bitwarden,
  pkgs-stable,
  ...
}:
let
  obsidian = pkgs.symlinkJoin {
    name = "${pkgs.obsidian.pname}-${pkgs.obsidian.version}";
    paths = [ pkgs.obsidian ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/obsidian
      mkdir -p $out/lib/obsidian

      electron_wrapper=$(sed -n 's|^exec "\([^"]*\)" .*|\1|p' ${pkgs.obsidian}/bin/obsidian)
      if [ -z "$electron_wrapper" ]; then
        echo "Unable to find Electron executable in ${pkgs.obsidian}/bin/obsidian" >&2
        exit 1
      fi

      electron_bin=$(sed -n 's|^exec "\([^"]*\)" .*|\1|p' "$electron_wrapper")
      if [ -z "$electron_bin" ]; then
        echo "Unable to find Electron binary in $electron_wrapper" >&2
        exit 1
      fi

      electron_dir=$(dirname "$electron_bin")
      mkdir -p $out/lib/obsidian/electron
      ln -s "$electron_dir"/* $out/lib/obsidian/electron/
      rm $out/lib/obsidian/electron/electron
      cp "$electron_bin" $out/lib/obsidian/electron/obsidian
      chmod +x $out/lib/obsidian/electron/obsidian

      sed "s|$electron_bin|$out/lib/obsidian/electron/obsidian|" "$electron_wrapper" \
        > $out/lib/obsidian/electron-wrapper
      chmod +x $out/lib/obsidian/electron-wrapper

      makeWrapper $out/lib/obsidian/electron-wrapper $out/bin/obsidian \
        --add-flags $out/share/obsidian/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}"
    '';
  };
in
lib.mkIf config.dotfiles.features.productivity.enable {
  environment.systemPackages =
    with pkgs-stable;
    [
      insync
      libreoffice
      obsidian
    ]
    ++ lib.optionals config.dotfiles.features.apps.bitwarden.enable [
      pkgs-bitwarden.bitwarden-desktop
    ];
}
