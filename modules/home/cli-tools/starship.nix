{ lib, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      format = "[](fg:mauve)$os$directory$git_branch$git_state$git_status$golang$nix_shell$hostname$fill$status$cmd_duration$jobs\n$character";
      add_newline = false;
      palette = lib.mkForce "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      os = {
        disabled = false;
        # symbol hardcoded in format to ensure the glyph survives nix serialization
        format = "[  ](bg:mauve fg:crust bold)";
        symbols = {
          NixOS = "";
          Linux = "";
        };
      };

      directory = {
        format = "[](fg:mauve bg:blue)[ $path$read_only ](bg:blue fg:crust bold)";
        truncation_length = 3;
        truncate_to_repo = false;
        read_only = "  ";
        read_only_style = "bg:blue fg:red";
      };

      git_branch = {
        format = "[](fg:blue bg:yellow)[ $symbol$branch(:$remote_branch) ](bg:yellow fg:crust)";
        symbol = " ";
      };

      git_state.format = "[ $state( $progress_current/$progress_total) ](bg:yellow fg:crust bold)";

      # bg:yellow is repeated in each status var to prevent background reset
      git_status = {
        format = "[$all_status$ahead_behind ](bg:yellow fg:crust)[](fg:yellow)";
        style = "bg:yellow fg:crust";
        conflicted = "[✗](bg:yellow fg:red bold)";
        ahead = "[⇡\${count}](bg:yellow fg:crust bold)";
        behind = "[⇣\${count}](bg:yellow fg:crust bold)";
        diverged = "[⇡\${ahead_count}⇣\${behind_count}](bg:yellow fg:red bold)";
        untracked = "[?](bg:yellow fg:overlay0)";
        stashed = "[$](bg:yellow fg:crust)";
        modified = "[!](bg:yellow fg:overlay0)";
        staged = "[+](bg:yellow fg:crust bold)";
        renamed = "[»](bg:yellow fg:crust)";
        deleted = "[-](bg:yellow fg:red)";
      };

      golang = {
        format = "[](fg:green)[ $symbol($version) ](bg:green fg:crust)[](fg:green)";
        symbol = " ";
      };

      nix_shell = {
        format = "[](fg:teal)[ $symbol$name ](bg:teal fg:crust)[](fg:teal)";
        symbol = " ";
        impure_msg = "impure";
        pure_msg = "pure";
      };

      hostname = {
        ssh_only = true;
        format = "[](fg:mauve)[ @$hostname ](bg:mauve fg:crust bold)[](fg:mauve)";
      };

      fill.symbol = " ";

      status = {
        disabled = false;
        format = "[](fg:surface0)[ $symbol ]($style)[](fg:surface0)";
        style = "bg:surface0 fg:red";
        success_style = "bg:surface0 fg:green";
        success_symbol = "✔";
        symbol = "✘";
        not_executable_symbol = "⊘";
        not_found_symbol = "?";
        signal_symbol = "⚡";
        map_symbol = true;
      };

      cmd_duration = {
        format = "[](fg:yellow)[ $duration ](bg:yellow fg:crust)[](fg:yellow)";
        min_time = 3000;
        show_milliseconds = false;
      };
      jobs = {
        format = "[](fg:surface0)[ $symbol$number ](bg:surface0 fg:teal)[](fg:surface0)";
        symbol = "⚙ ";
      };

      character = {
        format = "$symbol ";
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:peach)";
        vimcmd_replace_symbol = "[❮](bold fg:peach)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };

      aws.disabled = true;
      gcloud.disabled = true;
      azure.disabled = true;
      kubernetes.disabled = true;
      terraform.disabled = true;
      pulumi.disabled = true;
    };
  };
}
