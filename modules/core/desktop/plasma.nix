{
  pkgs,
  vars,
  lib,
  ...
}:
let
  inherit (vars) keyboardLayout;
in
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    configPackages = [ pkgs.kdePackages.plasma-desktop ];
  };

  services.xserver.xkb = {
    layout = keyboardLayout;
    variant = "";
  };

  environment.systemPackages =
    (with pkgs.kdePackages; [
      ark
      dolphin
      filelight
      gwenview
      kcalc
      kdeconnect-kde
      krdc
      krohnkite
      kscreen
      kwallet
      kwallet-pam
      kwalletmanager
      okular
      partitionmanager
      plasma-browser-integration
      plasma-desktop
      plasma-nm
      plasma-pa
      plasma-workspace
      plasma-workspace-wallpapers
      spectacle
      systemsettings
    ])
    ++ (with pkgs; [
      bibata-cursors
      haruna
      kdotool
      libnotify
      plasma-panel-colorizer
      python3
      (catppuccin-kde.override {
        flavour = [ "mocha" ];
        accents = [ "mauve" ];
      })
    ]);

  security.pam.services.plasmalogin.enableKwallet = true;
  security.pam.services.login.enableKwallet = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    khelpcenter
    konsole
  ];

  systemd.user.services = {
    "app-org.kde.discover.notifier@autostart".enable = false;
  };

  users.users.plasmalogin.extraGroups = [ "input" ];

  # Fix for https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
  nixpkgs.overlays = lib.singleton (
    final: prev: {
      kdePackages = prev.kdePackages // {
        plasma-workspace =
          let
            basePkg = prev.kdePackages.plasma-workspace;

            xdgdataPkg = pkgs.stdenv.mkDerivation {
              name = "${basePkg.name}-xdgdata";
              buildInputs = [ basePkg ];
              dontUnpack = true;
              dontFixup = true;
              dontWrapQtApps = true;
              installPhase = ''
                mkdir -p $out/share
                ( IFS=:
                  for DIR in $XDG_DATA_DIRS; do
                    if [[ -d "$DIR" ]]; then
                      cp -r $DIR/. $out/share/
                      chmod -R u+w $out/share
                    fi
                  done
                )
              '';
            };

            derivedPkg = basePkg.overrideAttrs {
              preFixup = ''
                for index in "''${!qtWrapperArgs[@]}"; do
                  if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                    unset -v "qtWrapperArgs[$((index+0))]"
                    unset -v "qtWrapperArgs[$((index+1))]"
                    unset -v "qtWrapperArgs[$((index+2))]"
                    unset -v "qtWrapperArgs[$((index+3))]"
                  fi
                done
                qtWrapperArgs=("''${qtWrapperArgs[@]}")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
              '';
            };
          in
          derivedPkg;
      };
    }
  );
}
