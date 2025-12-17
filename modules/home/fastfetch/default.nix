{
  lib,
  vars,
  ...
}:
let
  workEnable = vars.workEnable or false;
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        separator = "  ";
      };

      modules = [
        "break"
        # OS Section - Blue
        {
          type = "os";
          key = " 󱄅 ";
          keyColor = "blue";
          format = "{3} {12}";
        }
        {
          type = "kernel";
          key = " ├ 󰌽 ";
          keyColor = "blue";
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "blue";
        }
        {
          type = "shell";
          key = " └ 󰆍 ";
          keyColor = "blue";
        }
        # Desktop Section - Cyan
        {
          type = "de";
          key = " 󰧨 ";
          keyColor = "cyan";
        }
        {
          type = "wm";
          key = " ├ 󱂬 ";
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
          key = " ├ 󰇀 ";
          keyColor = "cyan";
        }
        {
          type = "terminal";
          key = " ├ 󰞷 ";
          keyColor = "cyan";
        }
        {
          type = "terminalfont";
          key = " └ 󰛖 ";
          keyColor = "cyan";
        }
        # Hardware Section - Magenta
        {
          type = "host";
          key = " 󰌢 ";
          keyColor = "magenta";
          format = "{5} {1} ({2})";
        }
        {
          type = "cpu";
          key = " ├ 󰻠 ";
          keyColor = "magenta";
        }
        {
          type = "gpu";
          key = " ├ 󰢮 ";
          keyColor = "magenta";
          format = "{1} {2}";
        }
        {
          type = "memory";
          key = " ├ 󰍛 ";
          keyColor = "magenta";
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = "magenta";
        }
        {
          type = "battery";
          key = " ├ 󰁹 ";
          keyColor = "magenta";
        }
        {
          type = "display";
          key = " └ 󰍹 ";
          keyColor = "magenta";
        }
        # Network Section - Green
        {
          type = "localip";
          key = " 󰛳 ";
          keyColor = "green";
          format = "{1}";
        }
        {
          type = "wifi";
          key = " ├ 󰖩 ";
          keyColor = "green";
          format = "{4} ({6})";
        }
        {
          type = "player";
          key = " ├ 󰥠 ";
          keyColor = "green";
        }
        {
          type = "media";
          key = " └ 󰝚 ";
          keyColor = "green";
        }
        # Time Section - Yellow
        {
          type = "uptime";
          key = " 󰅐 ";
          keyColor = "yellow";
        }
        {
          type = "datetime";
          key = " ├ 󰃭 ";
          keyColor = "yellow";
          format = "{1}-{4}-{11} {14}:{18}:{20}";
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
      ++ (
        if workEnable then
          [
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
            "colors"
          ]
        else
          [
            {
              type = "colors";
              key = " └   ";
              keyColor = "yellow";
              paddingLeft = 0;
            }
          ]
      );
    };
  };
}
