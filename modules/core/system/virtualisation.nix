{
  pkgs-stable,
  ...
}:
{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };
  };

  environment.systemPackages = [
    pkgs-stable.lazydocker
  ];
}
