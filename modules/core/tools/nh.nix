{
  config,
  pkgs,
  ...
}:
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = config.dotfiles.paths.dotfiles;
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
