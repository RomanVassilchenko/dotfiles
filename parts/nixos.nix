{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  username = "romanv";

  mkStable =
    system:
    import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

  gpuConfig = {
    intel = {
      drivers.intel.enable = true;
    };
    amd = {
      drivers.amdgpu.enable = true;
    };
  };

  hostNames = [
    "laptop-82sn"
    "ninkear"
  ];

  mkHostFacts =
    host: lib.recursiveUpdate (import ../hosts/default/common.nix) (import ../hosts/${host}/facts.nix);

  mkHost =
    host:
    let
      hostFacts = mkHostFacts host;
      system = hostFacts.system or "x86_64-linux";
      deviceType = hostFacts.deviceType or (if hostFacts.profile == "server" then "server" else "laptop");
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          username
          host
          hostFacts
          ;
        pkgs-stable = mkStable system;
      };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.llm-agents.overlays.default
            (final: prev: {
              t3code = final.callPackage ../packages/t3code { };

              # Enable MS-RDPECAM camera redirection and prefer passthrough formats
              freerdp = prev.freerdp.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.python3 ];
                buildInputs = old.buildInputs ++ [ final.linuxHeaders ];
                cmakeFlags = old.cmakeFlags ++ [ "-DCHANNEL_RDPECAM_CLIENT:BOOL=ON" ];
                postPatch = (old.postPatch or "") + ''
                  python3 - <<'PY'
                  from pathlib import Path

                  path = Path("channels/rdpecam/client/camera_device_main.c")
                  text = path.read_text()
                  old = """
                  	if (!initialized)
                  	{
                  		for (size_t dst = 0; dst < ARRAYSIZE(available); dst++)
                  		{
                  			const CAM_MEDIA_FORMAT dstFormat = available[dst];

                  			for (size_t src = 0; src < ARRAYSIZE(available); src++)
                  			{
                  				const CAM_MEDIA_FORMAT srcFormat = available[src];
                  				if (freerdp_video_conversion_supported(ecamToVideoFormat(srcFormat),
                  				                                       ecamToVideoFormat(dstFormat)))
                  				{
                  					formats[count++] = (CAM_MEDIA_FORMAT_INFO){ srcFormat, dstFormat };
                  				}
                  			}
                  		}
                  		initialized = TRUE;
                  	}
                  """
                  new = """
                  	if (!initialized)
                  	{
                  		for (size_t src = 0; src < ARRAYSIZE(available); src++)
                  		{
                  			const CAM_MEDIA_FORMAT format = available[src];
                  			if (freerdp_video_conversion_supported(ecamToVideoFormat(format),
                  			                                       ecamToVideoFormat(format)))
                  			{
                  				formats[count++] = (CAM_MEDIA_FORMAT_INFO){ format, format };
                  			}
                  		}

                  		for (size_t dst = 0; dst < ARRAYSIZE(available); dst++)
                  		{
                  			const CAM_MEDIA_FORMAT dstFormat = available[dst];

                  			for (size_t src = 0; src < ARRAYSIZE(available); src++)
                  			{
                  				const CAM_MEDIA_FORMAT srcFormat = available[src];
                  				if ((srcFormat == dstFormat) ||
                  				    !freerdp_video_conversion_supported(ecamToVideoFormat(srcFormat),
                  				                                       ecamToVideoFormat(dstFormat)))
                  				{
                  					continue;
                  				}

                  				formats[count++] = (CAM_MEDIA_FORMAT_INFO){ srcFormat, dstFormat };
                  			}
                  		}
                  		initialized = TRUE;
                  	}
                  """
                  if old not in text:
                      raise SystemExit("expected FreeRDP getSupportedFormats block not found")
                  path.write_text(text.replace(old, new))
                  PY
                '';
              });
            })
          ];
        }
        ../hosts/${host}
        ../features
        ../modules/drivers
        ../modules/core
        gpuConfig.${hostFacts.gpuProfile}
        inputs.stylix.nixosModules.stylix
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.lanzaboote.nixosModules.lanzaboote
      ]
      ++ lib.optional (builtins.pathExists ../private/default.nix) ../private;
    };
in
{
  perSystem =
    { pkgs, ... }:
    let
      dotCli = import ../lib/dot-cli.nix { inherit pkgs; };
    in
    {
      packages.dot = dotCli;
      apps.dot = {
        type = "app";
        program = "${dotCli}/bin/dot";
      };
    };

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
}
