{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      hackgen-nf-font
      ibm-plex
      inter
      maple-mono.NF
      material-icons
      minecraftia
      nerd-fonts.blex-mono
      nerd-fonts.im-writing
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
      powerline-fonts
      roboto
      roboto-mono
      terminus_font
    ];
  };
}
