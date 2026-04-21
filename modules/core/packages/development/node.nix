{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.features.development.enable {
  environment.systemPackages = with pkgs; [
    prettier
    ni
    nodejs
    playwright-driver.browsers
    pnpm
    typescript-language-server
  ];
}
