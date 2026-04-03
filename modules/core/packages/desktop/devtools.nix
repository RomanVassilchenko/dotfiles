{
  config,
  pkgs,
  pkgs-stable,
  lib,
  ...
}:
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = [
    pkgs-stable.bruno
    pkgs-stable.dbeaver-bin
    pkgs-stable.freerdp
    pkgs.nixd # keep on unstable — tracks nixpkgs
    pkgs-stable.postman
  ]
  ++ lib.optionals config.dotfiles.features.work.enable [ pkgs-stable.camunda-modeler ];
}
