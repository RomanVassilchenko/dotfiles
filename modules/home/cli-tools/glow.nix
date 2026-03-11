{ pkgs, config, ... }:
{
  home.packages = [ pkgs.glow ];

  xdg.configFile."glow/glow.yml".text = ''
    # Glow configuration
    pager: true
    width: 120
    style: "${config.xdg.configHome}/glow/catppuccin-mocha.json"
  '';

  xdg.configFile."glow/catppuccin-mocha.json".text = builtins.toJSON {
    document = {
      block_prefix = "\n";
      block_suffix = "\n";
      color = "#cdd6f4";
      margin = 2;
    };
    block_quote = {
      indent = 1;
      indent_token = "│ ";
      color = "#f5e0dc";
      italic = true;
    };
    paragraph = { };
    list = {
      level_indent = 2;
    };
    heading = {
      block_suffix = "\n";
      color = "#cba6f7";
      bold = true;
    };
    h1 = {
      prefix = "# ";
      color = "#cba6f7";
      bold = true;
    };
    h2 = {
      prefix = "## ";
      color = "#cba6f7";
      bold = true;
    };
    h3 = {
      prefix = "### ";
      color = "#cba6f7";
    };
    h4 = {
      prefix = "#### ";
      color = "#cba6f7";
    };
    h5 = {
      prefix = "##### ";
      color = "#cba6f7";
    };
    h6 = {
      prefix = "###### ";
      color = "#cba6f7";
    };
    text = { };
    strikethrough = {
      crossed_out = true;
    };
    emph = {
      italic = true;
      color = "#f5e0dc";
    };
    strong = {
      bold = true;
      color = "#f5e0dc";
    };
    hr = {
      color = "#585b70";
      format = "\n────────────────────────────────────────\n";
    };
    item = {
      block_prefix = "• ";
    };
    enumeration = {
      block_prefix = ". ";
    };
    task = {
      ticked = "[✓] ";
      unticked = "[ ] ";
    };
    link = {
      color = "#89b4fa";
      underline = true;
    };
    link_text = {
      color = "#f5c2e7";
      bold = true;
    };
    image = {
      color = "#89b4fa";
      underline = true;
    };
    image_text = {
      color = "#f5c2e7";
      format = "Image: {{.text}}";
    };
    code = {
      color = "#a6e3a1";
      background_color = "#313244";
    };
    code_block = {
      color = "#cdd6f4";
      margin = 2;
      chroma = {
        text = {
          color = "#cdd6f4";
        };
        error = {
          color = "#cdd6f4";
          background_color = "#f38ba8";
        };
        comment = {
          color = "#6c7086";
          italic = true;
        };
        comment_preproc = {
          color = "#f5c2e7";
        };
        keyword = {
          color = "#cba6f7";
        };
        keyword_reserved = {
          color = "#cba6f7";
        };
        keyword_namespace = {
          color = "#cba6f7";
        };
        keyword_type = {
          color = "#f9e2af";
        };
        operator = {
          color = "#89dceb";
        };
        punctuation = {
          color = "#bac2de";
        };
        name = {
          color = "#cdd6f4";
        };
        name_builtin = {
          color = "#f38ba8";
        };
        name_tag = {
          color = "#cba6f7";
        };
        name_attribute = {
          color = "#f9e2af";
        };
        name_class = {
          color = "#f9e2af";
        };
        name_constant = {
          color = "#fab387";
        };
        name_decorator = {
          color = "#f5c2e7";
        };
        name_exception = {
          color = "#cba6f7";
        };
        name_function = {
          color = "#89b4fa";
        };
        name_other = {
          color = "#cdd6f4";
        };
        literal = {
          color = "#fab387";
        };
        literal_number = {
          color = "#fab387";
        };
        literal_date = {
          color = "#fab387";
        };
        literal_string = {
          color = "#a6e3a1";
        };
        literal_string_escape = {
          color = "#f5c2e7";
        };
        generic_deleted = {
          color = "#f38ba8";
        };
        generic_emph = {
          italic = true;
        };
        generic_inserted = {
          color = "#a6e3a1";
        };
        generic_strong = {
          bold = true;
        };
        generic_subheading = {
          color = "#cba6f7";
        };
        background = {
          background_color = "#1e1e2e";
        };
      };
    };
    table = {
      center_separator = "┼";
      column_separator = "│";
      row_separator = "─";
    };
    definition_list = { };
    definition_term = {
      color = "#cba6f7";
      bold = true;
    };
    definition_description = {
      block_prefix = "\n  ";
    };
    html_block = { };
    html_span = { };
  };

  # Shell alias
  home.shellAliases = {
    md = "glow";
  };
}
