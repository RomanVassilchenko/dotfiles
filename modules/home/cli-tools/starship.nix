{ lib, config, ... }:
let
  c = config.lib.stylix.colors;
in
{
  programs.starship.enable = true;
  programs.starship.settings = {
    format = "[](fg:mauve)$os$directory$custom$git_branch$git_state$git_status$golang$nix_shell$hostname$fill$status$cmd_duration$jobs\n$character";
    add_newline = false;
    palette = lib.mkForce "stylix";

    palettes.stylix = {
      mauve = "#${c.base0E}";
      blue = "#${c.base0D}";
      yellow = "#${c.base0A}";
      green = "#${c.base0B}";
      teal = "#${c.base0C}";
      red = "#${c.base08}";
      peach = "#${c.base09}";
      crust = "#${c.base00}";
      text = "#${c.base05}";
      overlay0 = "#${c.base03}";
      surface0 = "#${c.base02}";
    };

    os = {
      disabled = false;
      format = "[  ](bg:mauve fg:crust bold)";
      symbols = {
        NixOS = "";
        Linux = "";
      };
    };

    directory = {
      format = "[](fg:mauve bg:blue)[ $path$read_only ](bg:blue fg:crust bold)";
      truncation_length = 3;
      truncate_to_repo = false;
      read_only = "  ";
      read_only_style = "bg:blue fg:red";
    };

    custom.dir_close = {
      command = "echo -n ''";
      when = "! git rev-parse --git-dir > /dev/null 2>&1";
      format = "[](fg:blue)";
      shell = [
        "bash"
        "--norc"
        "--noprofile"
      ];
    };

    git_branch = {
      format = "[](fg:blue bg:yellow)[ $symbol$branch(:$remote_branch) ](bg:yellow fg:crust)";
      symbol = " ";
    };

    git_state.format = "[ $state( $progress_current/$progress_total) ](bg:yellow fg:crust bold)";

    git_status = {
      format = "[$all_status$ahead_behind ](bg:yellow fg:crust)[](fg:yellow)";
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
      format = "[$symbol]($style)";
      style = "bold fg:red";
      success_style = "bold fg:green";
      success_symbol = "";
      symbol = " ✗";
      not_executable_symbol = " ⊘";
      not_found_symbol = " ?";
      signal_symbol = " ⚡";
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
}
