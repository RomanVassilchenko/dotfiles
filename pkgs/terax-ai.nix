{
  autoPatchelfHook,
  cairo,
  dpkg,
  fetchurl,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk3,
  lib,
  libsoup_3,
  stdenv,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "terax";
  version = "0.7.3";

  src = fetchurl {
    url = "https://github.com/crynta/terax-ai/releases/download/v${version}/Terax_${version}_amd64.deb";
    hash = "sha256-RpCTxu1caJkqW1v5Vz6lLFF+277darvw501izz9/AJo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];

  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/bin usr/share $out/
    runHook postInstall
  '';

  postFixup = ''
    wrapGApp $out/bin/terax \
      --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1
  '';

  meta = {
    description = "Open-source AI-native terminal emulator and development workspace";
    homepage = "https://github.com/crynta/terax-ai";
    changelog = "https://github.com/crynta/terax-ai/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "terax";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
