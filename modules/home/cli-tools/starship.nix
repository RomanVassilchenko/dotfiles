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
  programs.starship = {
    enable = true;
    package = pkgs-stable.starship;
    settings = {
      format = "$os$directory$git_branch$git_state$git_status$golang$nix_shell$buf$c$cmake$python$rust$nodejs$lua$nim$swift$zig$ocaml$haskell$java$julia$elixir$elm$scala$docker_context$package$fill$status$cmd_duration$jobs$hostname\n$character";
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
        format = "[$symbol](bold fg:mauve) ";
      };

      directory = {
        format = "[$path$read_only](bold fg:blue) ";
        truncation_length = 3;
        truncate_to_repo = false;
        read_only = " 󰌾";
        read_only_style = "fg:red";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = "󰇚 ";
          "Music" = "󰎆 ";
          "Pictures" = "󰉏 ";
        };
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)](fg:yellow) ";
        symbol = " ";
      };

      git_state.format = "[$state( $progress_current/$progress_total)](bold fg:yellow) ";

      git_status = {
        format = "[$all_status$ahead_behind](fg:yellow) ";
        style = "fg:yellow";
        conflicted = "[ \${count}](bold fg:red)";
        ahead = "[󰁞 \${count}](bold fg:green)";
        behind = "[󰁆 \${count}](bold fg:peach)";
        diverged = "[󰹺 ⇕\${ahead_count}/\${behind_count}](bold fg:red)";
        untracked = "[ \${count}](fg:overlay0)";
        stashed = "[ \${count}](fg:mauve)";
        modified = "[ \${count}](fg:overlay0)";
        staged = "[ \${count}](bold fg:green)";
        renamed = "[ \${count}](fg:teal)";
        deleted = "[ \${count}](fg:red)";
      };

      golang = {
        format = "[$symbol$version](fg:green) ";
        symbol = " ";
      };

      nix_shell = {
        format = "[$symbol$name](fg:teal) ";
        symbol = " ";
        impure_msg = "impure";
        pure_msg = "pure";
      };

      buf = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      c = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      cmake = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      python = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      rust = {
        format = "[$symbol($version )](fg:blue)";
        symbol = "󱘗 ";
      };

      nodejs = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      lua = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      nim = {
        format = "[$symbol($version )](fg:blue)";
        symbol = "󰆥 ";
      };

      swift = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      zig = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      ocaml = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      haskell = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      java = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      julia = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      elixir = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      elm = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      scala = {
        format = "[$symbol($version )](fg:blue)";
        symbol = " ";
      };

      docker_context = {
        format = "[$symbol$context](fg:blue) ";
        symbol = " ";
      };

      package = {
        format = "[$symbol$version](fg:blue) ";
        symbol = "󰏗 ";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname](bold fg:mauve) ";
        ssh_symbol = " ";
      };

      fill.symbol = " ";

      status = {
        disabled = false;
        format = "[$symbol]($style) ";
        style = "bold fg:red";
        success_style = "bold fg:green";
        success_symbol = "";
        symbol = " x";
        not_executable_symbol = " ⊘";
        not_found_symbol = " ?";
        signal_symbol = " x";
        map_symbol = false;
      };

      cmd_duration = {
        format = "[󰔛 $duration](bold fg:yellow) ";
        min_time = 3000;
        show_milliseconds = false;
      };

      jobs = {
        format = "[$symbol$number](fg:teal) ";
        symbol = "⚙ ";
      };

      aws.symbol = " ";
      bun.symbol = " ";
      conda.symbol = " ";
      cpp.symbol = " ";
      crystal.symbol = " ";
      dart.symbol = " ";
      deno.symbol = " ";
      fennel.symbol = " ";
      fortran.symbol = " ";
      gcloud.symbol = " ";
      git_commit.tag_symbol = "  ";
      gradle.symbol = " ";
      guix_shell.symbol = " ";
      haxe.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      meson.symbol = "󰔷 ";
      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        AlmaLinux = " ";
        Amazon = " ";
        Android = " ";
        AOSC = " ";
        Arch = " ";
        Artix = " ";
        CachyOS = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Elementary = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Ios = "󰀷 ";
        Kali = " ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        Nobara = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        Redox = "󰀘 ";
        RockyLinux = " ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Void = " ";
        Windows = "󰍲 ";
        Zorin = " ";
      };
      perl.symbol = " ";
      php.symbol = " ";
      pijul_channel.symbol = " ";
      pixi.symbol = "󰏗 ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      xmake.symbol = " ";

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
