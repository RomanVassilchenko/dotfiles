{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    prettier
    nodejs
    playwright-driver.browsers
    pnpm
    typescript-language-server
  ];
}
