{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  publicHostsDir = ../hosts;
  privateHostsDir = ../private/hosts;
  hostDefaults = import ../hosts/default/common.nix;

  mkStable =
    system:
    import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

  mkBitwarden =
    system:
    import inputs.nixpkgs-bitwarden {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-39.8.10" ];
      };
    };

  gpuConfig = {
    intel = {
      drivers.intel.enable = true;
    };
    amd = {
      drivers.amdgpu.enable = true;
    };
  };

  hostDirs = [ publicHostsDir ] ++ lib.optional (builtins.pathExists privateHostsDir) privateHostsDir;

  hostNames =
    let
      excluded = [
        "default"
        "profiles"
        "template"
      ];
      namesFrom =
        hostsDir: requireHardware:
        lib.attrNames (
          lib.filterAttrs (
            name: type:
            type == "directory"
            && !(builtins.elem name excluded)
            && builtins.pathExists (hostsDir + "/${name}/default.nix")
            && (!requireHardware || builtins.pathExists (hostsDir + "/${name}/hardware.nix"))
          ) (builtins.readDir hostsDir)
        );
    in
    lib.unique (
      (namesFrom publicHostsDir true)
      ++ (if builtins.pathExists privateHostsDir then namesFrom privateHostsDir false else [ ])
    );

  mkHost =
    host:
    let
      publicHostPath = publicHostsDir + "/${host}";
      privateHostPath = privateHostsDir + "/${host}";
      hasPublicHost = builtins.pathExists (publicHostPath + "/default.nix");
      hasPrivateHost = builtins.pathExists (privateHostPath + "/default.nix");
      publicHostModule = if hasPublicHost then import publicHostPath else { };
      privateHostModule = if hasPrivateHost then import privateHostPath else { };
      hostConfig = lib.recursiveUpdate (lib.recursiveUpdate hostDefaults (
        publicHostModule.dotfiles or { }
      )) (privateHostModule.dotfiles or { });
      system = hostConfig.host.system or "x86_64-linux";
      profile = hostConfig.host.profile or "workstation";
      deviceType = hostConfig.host.deviceType or (if profile == "server" then "server" else "laptop");
      gpuProfile = hostConfig.host.gpuProfile or null;
      username = hostConfig.user.name or "youruser";
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          username
          host
          ;
        hostDefaults = hostDefaults;
        pkgs-bitwarden = mkBitwarden system;
        pkgs-stable = mkStable system;
      };
      modules = [
        {
          nixpkgs.overlays = [
            inputs.llm-agents.overlays.default
            (final: prev: {
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
        ../features
        ../modules/drivers
        ../modules/core
      ]
      ++ lib.optional hasPublicHost publicHostPath
      ++ lib.optional hasPrivateHost privateHostPath
      ++ lib.optional (gpuProfile != null) gpuConfig.${gpuProfile}
      ++ [
        inputs.stylix.nixosModules.stylix
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.helium-browser.nixosModules.default
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
        meta.description = "Manage and rebuild these NixOS dotfiles";
      };
    };

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
}
