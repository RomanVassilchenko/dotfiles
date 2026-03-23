{ pkgs-stable, ... }:
{
  programs.fzf = {
    enable = true;
    package = pkgs-stable.fzf;
    enableZshIntegration = true;
    defaultOptions = [
      "--margin=1"
      "--layout=reverse"
      "--border=none"
      "--info='hidden'"
      "--header=''"
      "--prompt='/ '"
      "-i"
      "--no-bold"
    ];
  };
}
