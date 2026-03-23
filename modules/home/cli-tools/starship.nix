{
  pkgs-stable,
  lib,
  config,
  ...
}:
let
  catppuccinMocha = {
    base00 = "1e1e2e";
    base02 = "313244";
    base03 = "45475a";
    base05 = "cdd6f4";
    base08 = "f38ba8";
    base09 = "fab387";
    base0A = "f9e2af";
    base0B = "a6e3a1";
    base0C = "94e2d5";
    base0D = "89b4fa";
    base0E = "cba6f7";
  };
  c = if (config.stylix.enable or false) then config.lib.stylix.colors else catppuccinMocha;
in
{
  programs.starship.enable = true;
  programs.starship.package = pkgs-stable.starship;
  programs.starship.settings = {
    format = "[](fg:mauve)$os$directory\${custom.dir_close}$git_branch$git_state$git_status$golang\${custom.git_close}$nix_shell$buf$c$python$rust$nodejs$lua$nim$swift$zig$ocaml$haskell$java$julia$elixir$elm$scala$docker_context$package$fill$status$cmd_duration$jobs$hostname\n$character";
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
      format = "[ $symbol ](bg:mauve fg:crust bold)";
      symbols = {
        NixOS = "";
        Linux = "";
      };
    };

    directory = {
      format = "[](fg:mauve bg:blue)[ $path$read_only ](bg:blue fg:crust bold)";
      truncation_length = 3;
      truncate_to_repo = false;
      read_only = " 󰌾";
      read_only_style = "bg:blue fg:red";
      substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = "󰇚 ";
        "Music" = "󰎆 ";
        "Pictures" = "󰉏 ";
        "Development" = "󰲋 ";
        "dotfiles" = "󰒓 ";
      };
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

    custom.git_close = {
      command = "echo -n ''";
      when = "git rev-parse --git-dir > /dev/null 2>&1 && ! test -f go.mod";
      format = "[](fg:yellow)";
      shell = [
        "bash"
        "--norc"
        "--noprofile"
      ];
    };

    git_branch = {
      format = "[](fg:blue bg:yellow)[$symbol$branch(:$remote_branch) ](bg:yellow fg:crust)";
      symbol = " ";
    };

    git_state.format = "[ $state( $progress_current/$progress_total) ](bg:yellow fg:crust bold)";

    git_status = {
      format = "[$all_status$ahead_behind ](bg:yellow fg:crust)";
      style = "bg:yellow fg:crust";
      conflicted = "[✗](bg:yellow fg:red bold)";
      ahead = "[⇡\${count}](bg:yellow fg:crust bold)";
      behind = "[⇣\${count}](bg:yellow fg:crust bold)";
      diverged = "[⇡\${ahead_count}⇣\${behind_count}](bg:yellow fg:red bold)";
      untracked = "[?\${count}](bg:yellow fg:overlay0)";
      stashed = "[$\${count}](bg:yellow fg:crust)";
      modified = "[!\${count}](bg:yellow fg:overlay0)";
      staged = "[+\${count}](bg:yellow fg:crust bold)";
      renamed = "[»\${count}](bg:yellow fg:crust)";
      deleted = "[-\${count}](bg:yellow fg:red)";
    };

    golang = {
      format = "[](fg:yellow bg:green)[ $symbol$version ](bg:green fg:crust)[](fg:green)";
      symbol = "󰟓 ";
    };

    nix_shell = {
      format = "[](fg:teal)[ $symbol$name ](bg:teal fg:crust)[](fg:teal)";
      symbol = " ";
      impure_msg = "impure";
      pure_msg = "pure";
    };

    # Language modules — all use blue for consistency
    buf = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    c = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    python = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    rust = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    nodejs = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    lua = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    nim = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = "󰆥 ";
    };

    swift = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    zig = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    ocaml = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    haskell = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    java = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    julia = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    elixir = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    elm = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    scala = {
      format = "[](fg:blue)[ $symbol($version) ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    docker_context = {
      format = "[](fg:blue)[ $symbol$context ](bg:blue fg:crust)[](fg:blue)";
      symbol = " ";
    };

    package = {
      format = "[](fg:blue)[ $symbol$version ](bg:blue fg:crust)[](fg:blue)";
      symbol = "󰏗 ";
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
      format = "[](fg:yellow)[✗ ](bold fg:red bg:yellow)[$duration ](bg:yellow fg:crust)[](fg:yellow)";
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
