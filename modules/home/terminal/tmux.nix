{
  dotfiles,
  pkgs-stable,
  ...
}:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;

    plugins = with pkgs-stable.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig =
          "set -g @continuum-save-interval '10'"
          + (if dotfiles.host.isServer then "" else "\nset -g @continuum-restore 'on'");
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_pane_active_border_style "fg=#cba6f7"
          set -g @catppuccin_status_modules_right "session date_time"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
    ];

    extraConfig = ''
      # True color
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Window management
      set -g renumber-windows on
      set -g focus-events on
      setw -g pane-base-index 1

      # Intuitive splits keeping current path
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
