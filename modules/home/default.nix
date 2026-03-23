{ ... }:
{
  imports = [
    ./apps
    ./cli-tools
    ./config
    ./desktop
    ./editors
    ./fastfetch
    ./scripts
    ./shell
    ./terminal
  ];

  systemd.user.startServices = "sd-switch";
}
