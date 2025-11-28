# Fzf is a general-purpose command-line fuzzy finder.
{ lib, ... }:
let
  accent = "#89b4fa"; # Blue accent
  foreground = "#cdd6f4"; # Light foreground
  muted = "#6c7086"; # Muted gray
in
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = lib.mkForce {
      "fg+" = accent;
      "bg+" = "-1";
      "fg" = foreground;
      "bg" = "-1";
      "prompt" = muted;
      "pointer" = accent;
    };
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
