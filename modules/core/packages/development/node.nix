{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodePackages.prettier
    nodejs
    playwright-driver.browsers
    pnpm
    typescript-language-server
  ];
}
