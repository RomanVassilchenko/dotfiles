{ pkgs, ... }:
let
  # Panel Colorizer - Latte-Dock style customization for Plasma panels
  panelColorizer = pkgs.stdenvNoCC.mkDerivation {
    pname = "plasma-panel-colorizer";
    version = "5.4.0";

    src = pkgs.fetchFromGitHub {
      owner = "luisbocanegra";
      repo = "plasma-panel-colorizer";
      rev = "v5.4.0";
      sha256 = "sha256-8cjOyQzX3MOcXLux0raiAlx6kNreLa5jGdGQDlFNGiw=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer
      cp -r package/* $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer/
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Latte-Dock and WM status bar customization for Plasma panel";
      homepage = "https://github.com/luisbocanegra/plasma-panel-colorizer";
      license = licenses.gpl3;
    };
  };

  # Window Title - Shows active window title and icon
  windowTitle = pkgs.stdenvNoCC.mkDerivation {
    pname = "plasma6-window-title-applet";
    version = "0.9.0";

    src = pkgs.fetchFromGitHub {
      owner = "dhruv8sh";
      repo = "plasma6-window-title-applet";
      rev = "v0.9.0";
      sha256 = "sha256-pFXVySorHq5EpgsBz01vZQ0sLAy2UrF4VADMjyz2YLs=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
      cp -r * $out/share/plasma/plasmoids/org.kde.windowtitle/
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Shows application title and icon of active window";
      homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
      license = licenses.gpl2;
    };
  };

  # Move Windows to Desktops - KWin script for window management
  moveWindowsToDesktopsSrc = pkgs.fetchFromGitLab {
    owner = "carmanaught";
    repo = "kwin-scripts";
    rev = "master";
    sha256 = "sha256-xdExLEYfkX4L/hY/Z5PG0vC6IxsIclbgn/pw0SoZaL4=";
  };

  # Note: Simple Separator widget is not included yet as its GitHub repository
  # could not be found. It remains installed from your manual installation for now.
in
{
  home.packages = [
    panelColorizer
    windowTitle
  ];

  # KWin scripts must be installed to ~/.local/share/kwin/scripts/ for Plasma 6
  xdg.dataFile."kwin/scripts/move-windows-to-desktops" = {
    source = "${moveWindowsToDesktopsSrc}/move-windows-to-desktops";
    recursive = true;
  };
}
