# Tmux - Terminal multiplexer with Catppuccin Mocha Mauve theme
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    prefix = "C-a";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          # Catppuccin Mocha Mauve configuration
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"

          # Use mauve as the primary accent color
          set -g @catppuccin_pane_active_border_style "fg=#cba6f7"
          set -g @catppuccin_menu_selected_style "fg=#1e1e2e,bg=#cba6f7"

          # Status bar modules
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_window_text " #W"
          set -g @catppuccin_status_left_separator "█"
          set -g @catppuccin_status_right_separator "█"
          set -g @catppuccin_status_modules_right "directory session"
        '';
      }
    ];

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",*:Tc"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off

      # Split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Vi-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes with vi keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
    '';
  };
}
