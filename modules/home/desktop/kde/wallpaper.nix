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
  lockScreenWallpaperPlugin = "org.romanv.orientation-wallpaper";
  lockScreenWallpaperMetadata = pkgs.writeText "orientation-wallpaper-metadata.json" (
    builtins.toJSON {
      KPackageStructure = "Plasma/Wallpaper";
      KPlugin = {
        Id = lockScreenWallpaperPlugin;
        Name = "Orientation Wallpaper";
        License = "CC0-1.0";
        Authors = [ { Name = "romanv"; } ];
      };
    }
  );
  lockScreenWallpaperQml = pkgs.writeText "orientation-wallpaper-main.qml" ''
    import QtQuick

    Item {
      id: root

      property var configuration
      property string pluginName: "${lockScreenWallpaperPlugin}"
      property bool loading: image.status === Image.Loading

      Image {
        id: image

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        source: root.height > root.width ? "file://${verticalWallpaperFile}" : "file://${horizontalWallpaperFile}"
        sourceSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
      }
    }
  '';
  lockScreenWallpaperPackage = pkgs.runCommand "orientation-wallpaper" { } ''
    install -Dm644 ${lockScreenWallpaperMetadata} $out/share/plasma/wallpapers/${lockScreenWallpaperPlugin}/metadata.json
    install -Dm644 ${lockScreenWallpaperQml} $out/share/plasma/wallpapers/${lockScreenWallpaperPlugin}/contents/ui/main.qml
  '';
  lockScreenShellPackage = "org.romanv.plasma.desktop";
  lockScreenShell = pkgs.runCommand "orientation-lockscreen-shell" { } ''
    mkdir -p $out/share/plasma/shells
    cp -R ${pkgs.kdePackages.plasma-desktop}/share/plasma/shells/org.kde.plasma.desktop $out/share/plasma/shells/${lockScreenShellPackage}
    chmod -R u+w $out/share/plasma/shells/${lockScreenShellPackage}
    substituteInPlace $out/share/plasma/shells/${lockScreenShellPackage}/metadata.json \
      --replace '"Id": "org.kde.plasma.desktop"' '"Id": "${lockScreenShellPackage}"' \
      --replace '"Name": "Desktop"' '"Name": "Orientation Lock Screen"'
    substituteInPlace $out/share/plasma/shells/${lockScreenShellPackage}/contents/lockscreen/LockScreenUi.qml \
      --replace 'Window.window.requestActivate();' 'if (lockScreenRoot.width >= lockScreenRoot.height) { Window.window.requestActivate(); }' \
      --replace 'visible: opacity > 0' 'visible: opacity > 0 && lockScreenRoot.width >= lockScreenRoot.height'
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
    lockScreenShell
    lockScreenWallpaperPackage
    setWallpapersByOrientation
  ];

  programs.plasma.configFile = {
    plasmashellrc.Shell.ShellPackage = lockScreenShellPackage;

    kscreenlockerrc = {
      Greeter.WallpaperPlugin = lockScreenWallpaperPlugin;
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
