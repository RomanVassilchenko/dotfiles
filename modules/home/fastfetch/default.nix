{
  lib,
  host,
  ...
}:
let
  vars = import ../../../hosts/${host}/variables.nix;
  workEnable = vars.workEnable or false;
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "cyan";
          output = "white";
        };
        separator = " ➜  ";
      };

      # logo = {
      #   source = ./nixos.png;
      #   type = "kitty-direct";
      #   height = 10;
      #   width = 20;
      #   padding = {
      #     top = 2;
      #     left = 2;
      #   };
      # };

      modules = [
        "break"
        {
          type = "os";
          key = "OS";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = "blue";
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "blue";
        }
        {
          type = "shell";
          key = " └  ";
          keyColor = "blue";
        }
        "break"
        {
          type = "wm";
          key = "WM   ";
          keyColor = "cyan";
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = "cyan";
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = "cyan";
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = "cyan";
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = "cyan";
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = "cyan";
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC   ";
          keyColor = "magenta";
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7} GHz";
          key = " ├  ";
          keyColor = "magenta";
        }
        {
          type = "gpu";
          format = "{1} {2} @ {12} GHz";
          key = " ├ 󰢮 ";
          keyColor = "magenta";
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = "magenta";
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = "magenta";
        }
        {
          type = "monitor";
          key = " ├  ";
          keyColor = "magenta";
        }
        {
          type = "player";
          key = " ├ 󰥠 ";
          keyColor = "magenta";
        }
        {
          type = "media";
          key = " └ 󰝚 ";
          keyColor = "magenta";
        }
        "break"
        {
          type = "uptime";
          key = "TIME";
          keyColor = "yellow";
        }
        {
          type = "command";
          key = " ├ 󱦟 ";
          keyColor = "yellow";
          text = ''
            if [ "$(uname -s)" = "Darwin" ]; then
              ts=$(stat -f %B /)
            else
              ts=$(stat -c %W / 2>/dev/null)
            fi
            now=$(date +%s)
            if [ -z "$ts" ] || [ "$ts" = 0 ]; then
              printf "n/a"
            else
              days=$(( (now - ts) / 86400 ))
              printf "%s days" "$days"
            fi
          '';
          format = "System age — {result}";
        }
      ]
      ++ lib.optionals workEnable [
        {
          type = "command";
          key = " ├ 󰙴 ";
          keyColor = "yellow";
          text = ''
            career_start=$(date -d '2023-12-11 09:00 +0500' +%s)
            now=$(date -d '09:00 +0500' +%s)
            days=$(( (now - career_start) / 86400 ))
            printf "since Dec 11 2023 — %s days" "$days"
          '';
          format = "Career — {result}";
        }
        {
          type = "command";
          key = " ├ 󰏫 ";
          keyColor = "yellow";
          text = ''
            career_start=$(date -d '2023-12-11 09:00 +0500' +%s)
            matrix_start=$(date -d '2023-12-11 09:00 +0500' +%s)
            staff_start=$(date -d '2024-08-11 09:00 +0500' +%s)
            bereke_start=$(date -d '2025-09-19 09:00 +0500' +%s)
            now=$(date -d '09:00 +0500' +%s)
            matrix_days=$(( (staff_start - matrix_start) / 86400 ))
            staff_days=$(( (bereke_start - staff_start) / 86400 ))
            ozon_days=$(( matrix_days + staff_days ))
            career_days=$(( (now - career_start) / 86400 ))
            percent=$(awk -v a=$ozon_days -v b=$career_days 'BEGIN{printf "%.1f", 100*a/b}')
            printf "%s days (%s%% of career)" "$ozon_days" "$percent"
          '';
          format = "Ozon — {result}";
        }
        {
          type = "command";
          key = " │  ├ 󱊈 ";
          keyColor = "yellow";
          text = ''
            matrix_start=$(date -d '2023-12-11 09:00 +0500' +%s)
            staff_start=$(date -d '2024-08-11 09:00 +0500' +%s)
            bereke_start=$(date -d '2025-09-19 09:00 +0500' +%s)
            matrix_days=$(( (staff_start - matrix_start) / 86400 ))
            staff_days=$(( (bereke_start - staff_start) / 86400 ))
            ozon_days=$(( matrix_days + staff_days ))
            percent=$(awk -v a=$matrix_days -v b=$ozon_days 'BEGIN{printf "%.1f", 100*a/b}')
            printf "%s days (%s%% of Ozon)" "$matrix_days" "$percent"
          '';
          format = "Matrix — {result}";
        }
        {
          type = "command";
          key = " │  └ 󱊈 ";
          keyColor = "yellow";
          text = ''
            matrix_start=$(date -d '2023-12-11 09:00 +0500' +%s)
            staff_start=$(date -d '2024-08-11 09:00 +0500' +%s)
            bereke_start=$(date -d '2025-09-19 09:00 +0500' +%s)
            matrix_days=$(( (staff_start - matrix_start) / 86400 ))
            staff_days=$(( (bereke_start - staff_start) / 86400 ))
            ozon_days=$(( matrix_days + staff_days ))
            percent=$(awk -v a=$staff_days -v b=$ozon_days 'BEGIN{printf "%.1f", 100*a/b}')
            printf "%s days (%s%% of Ozon)" "$staff_days" "$percent"
          '';
          format = "Staff — {result}";
        }
        {
          type = "command";
          key = " └ 󰳼 ";
          keyColor = "yellow";
          text = ''
            career_start=$(date -d '2023-12-11 09:00 +0500' +%s)
            bereke_start=$(date -d '2025-09-19 09:00 +0500' +%s)
            now=$(date -d '09:00 +0500' +%s)
            bereke_days=$(( (now - bereke_start) / 86400 ))
            career_days=$(( (now - career_start) / 86400 ))
            percent=$(awk -v a=$bereke_days -v b=$career_days 'BEGIN{printf "%.1f", 100*a/b}')
            printf "%s days (%s%% of career)" "$bereke_days" "$percent"
          '';
          format = "Bereke Bank — {result}";
        }
      ];
    };
  };
}
