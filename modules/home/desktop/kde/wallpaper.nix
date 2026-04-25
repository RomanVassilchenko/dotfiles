{
  dotfiles,
  lib,
  pkgs,
  ...
}:
let
  horizontalWallpaperFile = ../../../../wallpapers/wallpaper_horizontal.png;
  verticalWallpaperFile = ../../../../wallpapers/wallpaper_vertical.png;
  horizontalWallpaper = "file://${dotfiles.paths.dotfiles}/wallpapers/wallpaper_horizontal.png";
  verticalWallpaper = "file://${dotfiles.paths.dotfiles}/wallpapers/wallpaper_vertical.png";
  packagedWallpaper = "Wallpaper";
  packagedWallpaperMetadata = pkgs.writeText "wallpaper-metadata.json" (
    builtins.toJSON {
      KPlugin = {
        Id = packagedWallpaper;
        Name = packagedWallpaper;
        License = "CC0-1.0";
        Authors = [ { Name = "romanv"; } ];
      };
    }
  );
  packagedWallpaperPackage = pkgs.runCommand "kde-wallpaper" { } ''
    install -Dm644 ${horizontalWallpaperFile} $out/share/wallpapers/${packagedWallpaper}/contents/images/1672x941.png
    install -Dm644 ${verticalWallpaperFile} $out/share/wallpapers/${packagedWallpaper}/contents/images/941x1672.png
    install -Dm644 ${packagedWallpaperMetadata} $out/share/wallpapers/${packagedWallpaper}/metadata.json
  '';
  setWallpapersByOrientation = pkgs.writeShellScriptBin "kde-set-wallpapers" ''
    set -eu

    SLEEP="${pkgs.coreutils}/bin/sleep"
    KSCREEN="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
    QDBUS="${pkgs.qt6.qttools}/bin/qdbus"
    JQ="${pkgs.jq}/bin/jq"

    horizontal='${horizontalWallpaper}'
    vertical='${verticalWallpaper}'

    # Stylix applies its Plasma wallpaper at session start, so apply our
    # orientation-specific wallpapers slightly later.
    "$SLEEP" 5

    mapping="$($KSCREEN -j | "$JQ" -c --arg horizontal "$horizontal" --arg vertical "$vertical" '
      [
        .outputs[]
        | select(.enabled and .connected)
        | {
            screen: (.id - 1),
            image: (if .size.height > .size.width then $vertical else $horizontal end)
          }
      ]
    ')"

    script="var mapping = $mapping; var all = desktops(); for (var i = 0; i < all.length; ++i) { var d = all[i]; for (var j = 0; j < mapping.length; ++j) { var m = mapping[j]; if (m.screen !== d.screen) { continue; } d.wallpaperPlugin = \"org.kde.image\"; d.currentConfigGroup = new Array(\"Wallpaper\", \"org.kde.image\", \"General\"); d.writeConfig(\"Image\", m.image); d.reloadConfig(); break; } }"
    "$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script" >/dev/null 2>&1 || true
  '';
in
lib.mkIf dotfiles.features.desktop.plasma.enable {
  home.packages = [
    packagedWallpaperPackage
    setWallpapersByOrientation
  ];

  programs.plasma.configFile = {
    kscreenlockerrc = {
      Greeter.WallpaperPlugin = "org.kde.image";
      "Greeter/Wallpaper/org.kde.image/General" = {
        Image = packagedWallpaper;
        PreviewImage = "null";
      };
    };

    "plasma-org.kde.plasma.desktop-appletsrc" = {
      "Containments/1".wallpaperplugin = "org.kde.image";
      "Containments/1/Wallpaper/org.kde.image/General".Image = horizontalWallpaper;

      "Containments/81".wallpaperplugin = "org.kde.image";
      "Containments/81/Wallpaper/org.kde.image/General".Image = verticalWallpaper;

      "Containments/82".wallpaperplugin = "org.kde.image";
      "Containments/82/Wallpaper/org.kde.image/General".Image = horizontalWallpaper;
    };
  };

  xdg.configFile."autostart/kde-set-wallpapers.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Set Plasma Wallpapers
    Comment=Apply wallpapers by screen orientation
    Exec=${setWallpapersByOrientation}/bin/kde-set-wallpapers
    Terminal=false
    X-KDE-autostart-phase=3
    NoDisplay=true
  '';
}
