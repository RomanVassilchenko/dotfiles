# Zellij - Terminal multiplexer with Catppuccin Mocha Mauve theme
{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = false; # Don't auto-start, just make available
  };

  # Catppuccin Mocha Mauve theme configuration
  xdg.configFile."zellij/config.kdl".text = ''
    theme "catppuccin-mocha"
    default_layout "compact"
    pane_frames false
    simplified_ui true
    default_mode "normal"
    mouse_mode true
    copy_on_select true
    scrollback_editor "nvim"

    keybinds clear-defaults=true {
      normal {
        bind "Ctrl a" { SwitchToMode "tmux"; }
      }
      tmux {
        bind "Esc" { SwitchToMode "Normal"; }
        bind "Ctrl a" { Write 1; SwitchToMode "Normal"; }
        bind "|" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
        bind "c" { NewTab; SwitchToMode "Normal"; }
        bind "," { SwitchToMode "RenameTab"; }
        bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
        bind "n" { GoToNextTab; SwitchToMode "Normal"; }
        bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
        bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
        bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
        bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
        bind "d" { Detach; }
        bind "x" { CloseFocus; SwitchToMode "Normal"; }
        bind "1" { GoToTab 1; SwitchToMode "Normal"; }
        bind "2" { GoToTab 2; SwitchToMode "Normal"; }
        bind "3" { GoToTab 3; SwitchToMode "Normal"; }
        bind "4" { GoToTab 4; SwitchToMode "Normal"; }
        bind "5" { GoToTab 5; SwitchToMode "Normal"; }
      }
      shared_except "normal" {
        bind "Esc" { SwitchToMode "Normal"; }
      }
    }
  '';

  # Catppuccin Mocha theme with Mauve accent
  xdg.configFile."zellij/themes/catppuccin-mocha.kdl".text = ''
    themes {
      catppuccin-mocha {
        bg "#1e1e2e"      // base
        fg "#cdd6f4"      // text
        red "#f38ba8"
        green "#a6e3a1"
        blue "#89b4fa"
        yellow "#f9e2af"
        magenta "#cba6f7" // mauve - primary accent
        orange "#fab387"  // peach
        cyan "#94e2d5"    // teal
        black "#181825"   // mantle
        white "#cdd6f4"   // text
      }
    }
  '';
}
