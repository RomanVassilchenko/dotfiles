{
  lib,
  ...
}:
{
  programs.zsh.initContent = lib.mkAfter ''
    # ===========================================
    # zmv - Advanced Batch Rename/Move
    # ===========================================
    autoload -Uz zmv

    # ===========================================
    # Global Aliases (usable anywhere in command)
    # ===========================================
    alias -g NE='2>/dev/null'
    alias -g NO='>/dev/null'
    alias -g NUL='>/dev/null 2>&1'
    alias -g J='| jq'
    alias -g C='| wl-copy'
    alias -g G='| rg'

    # ===========================================
    # Search & Navigation Helpers
    # ===========================================
    fcd() {
      local query
      local dir
      query="''${1:-.}"
      dir=$(fd --type d --hidden --follow --exclude .git "$query" . | fzf \
        --prompt='󰉋 ' \
        --preview 'eza --tree --level=2 --color=always --icons=always {} 2>/dev/null') || return
      cd "$dir"
    }

    fe() {
      local query
      local file
      query="''${1:-.}"
      file=$(fd --type f --hidden --follow --exclude .git "$query" . | fzf \
        --prompt='󰈔 ' \
        --preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null') || return
      micro "$file"
    }

    frg() {
      local match file line
      match=$(rg --line-number --no-heading --color=always --smart-case "$@" | fzf \
        --ansi \
        --delimiter ':' \
        --prompt='󰱼 ' \
        --preview 'bat --color=always --style=numbers --highlight-line {2} --line-range {2}:$(({2}+80)) {1} 2>/dev/null') || return
      file=$(printf '%s' "$match" | cut -d: -f1)
      line=$(printf '%s' "$match" | cut -d: -f2)
      [ -n "$file" ] && micro +"$line" "$file"
    }

    ai-session() {
      local tool="''${1:-opencode}"
      case "$tool" in
        opencode)
          "$tool" "''${@:2}"
          ;;
        *)
          printf 'Unknown AI tool: %s\n' "$tool"
          return 1
          ;;
      esac
    }

    hs() {
      atuin stats "$@"
    }

    yy() {
      local cwd_file cwd
      cwd_file=$(mktemp -t yazi-cwd.XXXXXX) || return
      yazi "$@" --cwd-file="$cwd_file"
      cwd=$(command cat -- "$cwd_file" 2>/dev/null)
      command rm -f -- "$cwd_file"
      [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
    }

    # ===========================================
    # Suffix Aliases (type filename to open it)
    # ===========================================
    alias -s {png,jpg,jpeg,gif,webp,svg,bmp}=xdg-open
    alias -s {mp4,mkv,avi,mov,webm}=xdg-open
    alias -s {mp3,flac,wav,ogg}=xdg-open
    alias -s {pdf,epub}=xdg-open
    alias -s {html,htm}=xdg-open
    alias -s {doc,docx,odt,xls,xlsx,ppt,pptx}=xdg-open
    alias -s json=jless
    alias -s {txt,md,log}=bat
    alias -s {go,rs,py,js,ts,nix,sh,lua}=$EDITOR

    # ===========================================
    # dot CLI Completions
    # ===========================================
    _dot() {
      local -a commands
      commands=(
        'rebuild:Rebuild NixOS system'
        'rebuild-boot:Rebuild for next boot'
        'update:Update flake inputs and rebuild'
        'cleanup:Trash backup files, GC old generations'
        'backup:Backup dotfiles to ninkear'
        'server:Server management (rebuild, update)'
        'doctor:Run system health checks'
        'trim:Run fstrim for SSD'
        'help:Show help'
      )

      local -a rebuild_opts
      rebuild_opts=(
        '--dry:Show build/download plan without sudo'
        '--dry-activate:Build and preview activation changes'
        '--build:Build only, do not activate'
        '--test:Activate until next boot only'
        '--plain:Disable nix-output-monitor'
        '--cores:Limit CPU cores'
        '--jobs:Limit parallel jobs'
      )

      local -a server_subcmds
      server_subcmds=('rebuild:Pull and rebuild on ninkear' 'update:Sync, update flake, rebuild ninkear')

      case "$words[2]" in
        rebuild|rebuild-boot|update)
          _describe -t rebuild_opts 'options' rebuild_opts
          ;;
        server)
          _describe -t server_subcmds 'subcommands' server_subcmds
          ;;
        *)
          _describe -t commands 'dot commands' commands
          ;;
      esac
    }
    compdef _dot dot

    _choose() {
      _arguments -s -S \
        '(-h --help)'{-h,--help}'[show help]' \
        '(-V --version)'{-V,--version}'[show version]' \
        '(-c --character-wise)'{-c,--character-wise}'[choose fields by character number]' \
        '(-d --debug)'{-d,--debug}'[activate debug mode]' \
        '(-x --exclusive)'{-x,--exclusive}'[use exclusive ranges]' \
        '(-n --non-greedy)'{-n,--non-greedy}'[use non-greedy field separators]' \
        '--one-indexed[index from 1 instead of 0]' \
        '(-f --field-separator)'{-f,--field-separator}'[set field separator]:regex:' \
        '(-i --input)'{-i,--input}'[read input from file]:file:_files' \
        '(-o --output-field-separator)'{-o,--output-field-separator}'[set output field separator]:separator:' \
        '*:field range:'
    }
    compdef _choose choose

    _duf() {
      local -a devices fields styles themes
      devices=(local network fuse special loops binds)
      fields=(mountpoint size used avail usage inodes inodes_used inodes_avail inodes_usage type filesystem)
      styles=(unicode ascii)
      themes=(dark light ansi)

      _arguments -s -S \
        '-all[include pseudo, duplicate, inaccessible file systems]' \
        '-inodes[list inode information]' \
        '-json[output devices as JSON]' \
        '-version[show version]' \
        '-warnings[output warnings to stderr]' \
        '-hide[hide device classes]:device class:($devices)' \
        '-only[show only device classes]:device class:($devices)' \
        '-hide-fs[hide filesystems]:filesystem:' \
        '-only-fs[show only filesystems]:filesystem:' \
        '-hide-mp[hide mount points]:mount point:_files -/' \
        '-only-mp[show only mount points]:mount point:_files -/' \
        '-output[select output fields]:field:($fields)' \
        '-sort[sort output by field]:field:($fields)' \
        '-style[set output style]:style:($styles)' \
        '-theme[set color theme]:theme:($themes)' \
        '-width[set max output width]:columns:' \
        '-avail-threshold[set available-space warning thresholds]:thresholds:' \
        '-usage-threshold[set usage-bar warning thresholds]:thresholds:'
    }
    compdef _duf duf

    _tokei() {
      _arguments -s -S \
        '(-h --help)'{-h,--help}'[show help]' \
        '(-V --version)'{-V,--version}'[show version]' \
        '(-c --columns)'{-c,--columns}'[set strict column width]:columns:' \
        '(-e --exclude)'{-e,--exclude}'[ignore matching files or directories]:pattern:' \
        '(-f --files)'{-f,--files}'[show individual file statistics]' \
        '(-i --input)'{-i,--input}'[read previous tokei output]:file:_files' \
        '--hidden[count hidden files]' \
        '(-l --languages)'{-l,--languages}'[list supported languages]' \
        '--no-ignore[ignore all ignore files]' \
        '--no-ignore-parent[ignore parent ignore files]' \
        '--no-ignore-dot[ignore .ignore and .tokeignore]' \
        '--no-ignore-vcs[ignore VCS ignore files]' \
        '(-o --output)'{-o,--output}'[set output format]:format:(json yaml cbor)' \
        '--streaming[stream records]:mode:(simple json)' \
        '(-s --sort)'{-s,--sort}'[sort languages by column]:column:(files lines blanks code comments)' \
        '(-r --rsort)'{-r,--rsort}'[reverse sort languages by column]:column:(files lines blanks code comments)' \
        '(-t --types)'{-t,--types}'[filter by language types]:language:' \
        '(-C --compact)'{-C,--compact}'[hide embedded language statistics]' \
        '(-n --num-format)'{-n,--num-format}'[set number format]:format:(plain commas dots underscores)' \
        '(-v --verbose)'{-v,--verbose}'[increase log verbosity]' \
        '*:input:_files'
    }
    compdef _tokei tokei

    # opencode completion
    if command -v opencode >/dev/null 2>&1; then
      opencode_completion_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
      opencode_completion_file="$opencode_completion_dir/opencode.zsh"
      opencode_completion_tmp="$opencode_completion_file.$$"
      command mkdir -p "$opencode_completion_dir"

      if [[ ! -s "$opencode_completion_file" || "$commands[opencode]" -nt "$opencode_completion_file" ]]; then
        if opencode completion zsh >| "$opencode_completion_tmp" 2>/dev/null; then
          command mv -f "$opencode_completion_tmp" "$opencode_completion_file"
        else
          command rm -f "$opencode_completion_tmp"
        fi
      fi

      [[ -s "$opencode_completion_file" ]] && source "$opencode_completion_file"
      (( $+functions[_opencode_yargs_completions] )) && compdef _opencode_yargs_completions oc

      unset opencode_completion_dir opencode_completion_file opencode_completion_tmp
    fi

    if [ -f $HOME/.zshrc-personal ]; then
      source $HOME/.zshrc-personal
    fi
  '';
}
