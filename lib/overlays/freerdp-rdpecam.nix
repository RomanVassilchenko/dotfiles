final: prev: {
  freerdp = prev.freerdp.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.python3 ];
    buildInputs = (old.buildInputs or [ ]) ++ [ prev.linuxHeaders ];
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCHANNEL_RDPECAM_CLIENT:BOOL=ON" ];
    postPatch = (old.postPatch or "") + ''
      python3 ${./freerdp-rdpecam.py}
    '';
  });
}
