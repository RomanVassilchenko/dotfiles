{
  appimageTools,
  fetchurl,
  lib,
}:
let
  release = import ./release.nix;
in
appimageTools.wrapType2 {
  pname = "t3code";
  inherit (release) version;

  src = fetchurl {
    url = release.appImageUrl;
    hash = release.appImageHash;
    curlOptsList = [
      "--http1.1"
      "--ipv4"
      "--retry"
      "10"
      "--retry-all-errors"
      "--connect-timeout"
      "30"
    ];
  };

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/t3code.desktop" <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=T3 Code
    Comment=Minimal web GUI for coding agents
    Exec=t3code
    Icon=applications-development
    Terminal=false
    Categories=Development;
    StartupWMClass=T3 Code
    EOF
  '';

  meta = with lib; {
    description = "Minimal web GUI for coding agents";
    homepage = "https://github.com/pingdotgg/t3code";
    license = licenses.mit;
    mainProgram = "t3code";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
