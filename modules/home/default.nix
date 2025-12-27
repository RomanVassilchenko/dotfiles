# Home-manager configuration
# Each subfolder has its own default.nix with server/desktop logic
{ ... }:
{
  imports = [
    ./config
    ./shell
    ./cli-tools
    ./terminal
    ./editors
    ./scripts
    ./fastfetch
    ./apps
    ./desktop
  ];

  systemd.user.startServices = "sd-switch";
}
