{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles;
in
lib.mkIf cfg.host.isServer {
  environment.systemPackages = [ pkgs.t3code ];

  systemd.services.t3code = {
    description = "T3 Code server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      HOME = cfg.user.homeDirectory;
      T3CODE_HOME = "${cfg.user.homeDirectory}/Projects";
      XDG_CONFIG_HOME = "${cfg.user.homeDirectory}/.config";
      XDG_DATA_HOME = "${cfg.user.homeDirectory}/.local/share";
      XDG_CACHE_HOME = "${cfg.user.homeDirectory}/.cache";
    };

    serviceConfig = {
      ExecStart = "${pkgs.t3code}/bin/t3code serve --host 127.0.0.1 --port 3773 --base-dir ${cfg.user.homeDirectory}/Projects --no-browser";
      Restart = "always";
      RestartSec = "5s";
      User = cfg.user.name;
      WorkingDirectory = cfg.user.homeDirectory;
    };
  };
}
