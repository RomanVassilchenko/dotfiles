{ pkgs-stable, ... }:
{
  programs.fzf = {
    enable = true;
    package = pkgs-stable.fzf;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=45%"
      "--tmux=bottom,60%"
      "--margin=1"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline-right"
      "--prompt= "
      "--pointer=❯"
      "--marker=󰄬 "
      "--separator=─"
      "--scrollbar=│"
      "--preview-window=right,55%,border-left"
      "--color=fg:#cdd6f4,bg:-1,hl:#cba6f7"
      "--color=fg+:#cdd6f4,bg+:#313244,hl+:#cba6f7"
      "--color=info:#89b4fa,prompt:#94e2d5,pointer:#f38ba8"
      "--color=marker:#a6e3a1,spinner:#f9e2af,header:#6c7086"
      "-i"
    ];
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || sed -n \"1,200p\" {}'"
    ];
    changeDirWidgetOptions = [
      "--preview 'eza --tree --level=2 --color=always --icons=always {} 2>/dev/null'"
    ];
    historyWidgetOptions = [
      "--sort"
      "--exact"
      "--preview 'printf %s {}'"
    ];
  };
}
