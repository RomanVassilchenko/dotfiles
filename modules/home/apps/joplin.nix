{
  pkgs,
  lib,
  appConfig,
  ...
}:
{
  # Joplin - Note-taking app
  home.packages = [ pkgs.joplin-desktop ];

  # Autostart
  # Note: No CLI flag for tray start. Configure via Tools > Options > Application > "Start application minimised in the tray icon"
  xdg.configFile."autostart/joplin.desktop" = lib.mkIf appConfig.joplin.autostart {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Joplin
      Comment=Joplin - an open source note taking and to-do application
      Exec=${pkgs.joplin-desktop}/bin/joplin-desktop
      Icon=joplin
      Terminal=false
      Categories=Office;
      MimeType=x-scheme-handler/joplin;
      StartupWMClass=Joplin
    '';
  };

  # Catppuccin Mocha theme for Joplin
  # After rebuild, enable dark theme in Joplin: Tools > Options > Appearance > Theme > Dark
  # Optional: Install "Rich Markdown" plugin and enable "Add additional CSS classes" for enhanced styling
  xdg.configFile."joplin-desktop/userchrome.css".text = ''
    /* Catppuccin Mocha theme for Joplin - App UI styling */
    /* Source: https://github.com/catppuccin/joplin */

    :root {
      --ctp-mocha-rosewater: #f5e0dc;
      --ctp-mocha-flamingo: #f2cdcd;
      --ctp-mocha-pink: #f5c2e7;
      --ctp-mocha-mauve: #cba6f7;
      --ctp-mocha-red: #f38ba8;
      --ctp-mocha-maroon: #eba0ac;
      --ctp-mocha-peach: #fab387;
      --ctp-mocha-yellow: #f9e2af;
      --ctp-mocha-green: #a6e3a1;
      --ctp-mocha-teal: #94e2d5;
      --ctp-mocha-sky: #89dceb;
      --ctp-mocha-sapphire: #74c7ec;
      --ctp-mocha-blue: #89b4fa;
      --ctp-mocha-lavender: #b4befe;
      --ctp-mocha-text: #cdd6f4;
      --ctp-mocha-subtext1: #bac2de;
      --ctp-mocha-subtext0: #a6adc8;
      --ctp-mocha-overlay2: #9399b2;
      --ctp-mocha-overlay1: #7f849c;
      --ctp-mocha-overlay0: #6c7086;
      --ctp-mocha-surface2: #585b70;
      --ctp-mocha-surface1: #45475a;
      --ctp-mocha-surface0: #313244;
      --ctp-mocha-base: #1e1e2e;
      --ctp-mocha-mantle: #181825;
      --ctp-mocha-crust: #11111b;
      --font-face: "Inter", "Noto Sans", Arial, Helvetica, sans-serif;
      --font-mono: "JetBrainsMono Nerd Font", "Roboto Mono", Courier, monospace;
      --font-size: 13px;
      --icon-size: 16px;
      --regular: 400;
      --bolder: 600;
      --scroll-radius: 3px;
      --opacity-0-8: 0.8;
    }

    * { font-family: var(--font-face) !important; }

    html, body {
      background-color: var(--ctp-mocha-base) !important;
      font-size: var(--font-size) !important;
      font-weight: var(--regular) !important;
    }

    .CodeMirror-selected { background: #6B6B6B !important; }
    .rli-root { background-color: var(--ctp-mocha-base) !important; }

    .fa, .far, .fas {
      font-weight: 900 !important;
      font-family: "Font Awesome 5 Free" !important;
      font-size: var(--icon-size) !important;
    }

    ::placeholder { color: var(--ctp-mocha-lavender) !important; }

    ::-webkit-scrollbar-thumb {
      background-color: var(--ctp-mocha-surface0) !important;
      border-radius: var(--scroll-radius) !important;
    }

    .resizableLayoutItem > div { background-color: var(--ctp-mocha-base) !important; }

    /* Sidebar */
    .sidebar {
      background-color: var(--ctp-mocha-crust) !important;
      text-transform: uppercase;
      font-weight: var(--bolder);
    }

    i.icon-notes { display: none !important; }

    .sidebar > div > div > button span { color: var(--ctp-mocha-lavender) !important; }
    .sidebar > div > div > button:hover { opacity: var(--opacity-0-8); }

    .folders .list-item-container { background-color: var(--ctp-mocha-crust) !important; }
    .folders .list-item-container:hover { background-color: var(--ctp-mocha-overlay0) !important; }
    .folders .list-item-container a {
      text-transform: initial;
      color: var(--ctp-mocha-text) !important;
      font-weight: var(--regular);
    }
    .folders .list-item-container a:focus {
      color: var(--ctp-mocha-text) !important;
      background-color: var(--ctp-mocha-base) !important;
    }

    .tags .list-item-container {
      display: inline-block;
      line-height: 0 !important;
      padding: 0 !important;
      height: auto !important;
      background-color: var(--ctp-mocha-crust) !important;
    }
    .tags .list-item-container:hover { background-color: var(--ctp-mocha-overlay0) !important; }
    .tags .list-item-container a {
      padding-left: 12px !important;
      text-transform: initial;
      color: var(--ctp-mocha-text) !important;
      font-weight: var(--regular);
    }

    .sidebar > div:last-of-type > button {
      background-color: var(--ctp-mocha-mauve) !important;
      border: 0px !important;
      text-transform: uppercase;
      font-size: var(--font-size) !important;
    }
    .sidebar > div:last-of-type > button:hover { opacity: var(--opacity-0-8); }
    .sidebar > div:last-of-type > button > span { color: var(--ctp-mocha-crust) !important; }

    /* Note List */
    .note-list {
      background-color: var(--ctp-mocha-mantle) !important;
      border: none !important;
    }

    .cLdGCO, .cLdGCO > div { background-color: var(--ctp-mocha-mantle) !important; }
    .rli-noteList div { border: none !important; }

    div[height="50"] { background-color: var(--ctp-mocha-mantle) !important; }
    div[height="50"] input {
      border: none !important;
      color: var(--ctp-mocha-text) !important;
      background-color: var(--ctp-mocha-mantle) !important;
    }
    div[height="50"] button {
      background: transparent !important;
      color: var(--ctp-mocha-text) !important;
      border: 0 !important;
    }
    div[height="50"] button span { color: var(--ctp-mocha-text) !important; }

    .new-note-todo-buttons > button {
      background-color: var(--ctp-mocha-mauve) !important;
      border: none !important;
    }
    .new-todo-button > span { color: var(--ctp-mocha-crust) !important; }

    .search-bar { background-color: var(--ctp-mocha-crust) !important; }
    .icon-search { color: var(--ctp-mocha-mauve) !important; }
    .sort-order-reverse-button { background-color: var(--ctp-mocha-crust) !important; }
    .fa-calendar-alt { color: var(--ctp-mocha-mauve) !important; }
    .fa-long-arrow-alt-up { color: var(--ctp-mocha-mauve) !important; }

    .note-list .list-item-container { background-color: var(--ctp-mocha-mantle) !important; }
    .note-list .list-item-container:hover { background-color: var(--ctp-mocha-overlay1) !important; }
    .note-list-item:hover { background-color: var(--ctp-mocha-overlay0) !important; }
    .item-list.note-list .list-item-container::before { border: none !important; }
    .note-list-item::before { border: none !important; }
    .note-list .list-item-container a {
      text-transform: initial;
      color: var(--ctp-mocha-text) !important;
      font-weight: var(--regular);
    }

    .list-item-wrapper.-selected { background-color: var(--ctp-mocha-base) !important; }
    .note-list-item > .content.-selected { background-color: var(--ctp-mocha-surface2) !important; }
    .list-item-wrapper.-highlight-on-hover:hover { background-color: var(--ctp-mocha-surface1); }

    .item-list.note-list .list-item-container > a > span {
      overflow: hidden;
      text-overflow: ellipsis;
    }

    /* Editor */
    .rli-editor .cCOtNv > input {
      padding-top: 5px;
      background-color: var(--ctp-mocha-base) !important;
    }
    .title-input {
      background-color: var(--ctp-mocha-base) !important;
      color: var(--ctp-mocha-text) !important;
    }
    .editor-toolbar { background-color: transparent !important; }
    .editor-toolbar > div > a:hover { opacity: var(--opacity-0-8); }
    .editor-toolbar a[title="Spell checker"] { display: none !important; }
    .tox-toolbar { display: none !important; }
    .editor-toolbar button[title="Toggle editors"] { display: none !important; }

    .cJOYJm {
      background-color: var(--ctp-mocha-mauve) !important;
      margin: 0px !important;
      padding: 5px !important;
      font-size: var(--font-size) !important;
    }

    .rli-editor > div > div:empty { background-color: var(--ctp-mocha-base) !important; }
    .rli-editor > div > div > div > div > div > div > div:last-of-type {
      border-color: var(--ctp-mocha-base) !important;
    }

    div.sc-AxirZ.hagDvo, div.sc-AxirZ.hagDvo > div {
      background-color: var(--ctp-mocha-mantle) !important;
      color: var(--ctp-mocha-text) !important;
    }

    .note-search-bar, .note-search-bar > div > div {
      background-color: var(--ctp-mocha-base) !important;
      width: 100%;
      border: 0 !important;
    }
    .note-search-bar input {
      border: 0 !important;
      padding: 5px;
      color: var(--ctp-mocha-text) !important;
      background-color: var(--ctp-mocha-base) !important;
    }

    .tag-bar { background-color: transparent !important; }
    .tag-list > span {
      color: var(--ctp-mocha-mauve) !important;
      background-color: var(--ctp-mocha-crust) !important;
    }
    a[Title="Tags"] + div > span { display: none !important; }

    /* CodeMirror Editor */
    .cm-s-material-darker.CodeMirror {
      background-color: var(--ctp-mocha-base) !important;
      color: var(--ctp-mocha-text) !important;
    }
    .cm-header { color: var(--ctp-mocha-mauve) !important; }
    .cm-editor { background-color: var(--ctp-mocha-base) !important; }
    .cm-em, .cm-strong, .cm-strong.cm-em { color: var(--ctp-mocha-text) !important; }
    .cm-variable-2, .cm-variable-3, .cm-keyword { color: var(--ctp-mocha-text) !important; }
    .cm-s-material-darker .cm-variable-2.cm-rm-list-token { color: var(--ctp-mocha-text) !important; }

    .cm-url {
      color: var(--ctp-mocha-rosewater) !important;
      opacity: 1;
      text-decoration: underline;
    }
    .cm-link-text { color: var(--ctp-mocha-rosewater) !important; }
    pre.CodeMirror-line {
      color: var(--ctp-mocha-text) !important;
      background-color: none !important;
    }
    span.cm-string.cm-url.cm-overlay.cm-rm-link.cm-overlay.cm-rm-image {
      color: var(--ctp-mocha-mauve) !important;
    }
    pre.CodeMirror-line span.cm-comment {
      color: var(--ctp-mocha-overlay1) !important;
      background-color: none !important;
      border: 0 !important;
    }

    pre.CodeMirror-line span.CodeMirror-selectedtext { background: #6B6B6B !important; }
    div.CodeMirror span.cm-comment.cm-jn-inline-code {
      background-color: transparent !important;
      padding-right: 0 !important;
      padding-left: 0 !important;
    }
    div.CodeMirror span.cm-comment:not(.cm-jn-inline-code) {
      color: var(--ctp-mocha-text) !important;
      background-color: transparent !important;
    }
    div.CodeMirror div.cm-jn-code-block-background {
      background-color: var(--ctp-mocha-mantle) !important;
    }
    .cm-hr { color: var(--ctp-mocha-overlay0) !important; }

    .CodeMirror-cursor {
      border-left: 1px solid var(--ctp-mocha-rosewater) !important;
      border-right: none !important;
      width: 0 !important;
    }
    .cm-fat-cursor div.CodeMirror-cursor {
      width: 10px !important;
      border: 0 !important;
      background: var(--ctp-mocha-rosewater) !important;
    }

    .cm-header.cm-rm-header-token { color: var(--ctp-mocha-green) !important; }
    .cm-strong.cm-rm-strong-token { color: var(--ctp-mocha-blue) !important; }
    pre.cm-rm-blockquote.CodeMirror-line { font-style: italic !important; }

    /* Command palette */
    div.modal-dialog { background-color: var(--ctp-mocha-mantle) !important; }
    .modal-dialog > div > input {
      background-color: var(--ctp-mocha-crust) !important;
      color: var(--ctp-mocha-text) !important;
    }
    .modal-dialog > .item-list {
      background-color: var(--ctp-mocha-crust) !important;
      color: var(--ctp-mocha-text) !important;
    }
    .modal-dialog > .item-list div[class="selected"] {
      background-color: var(--ctp-mocha-surface2) !important;
    }
    .modal-dialog > .item-list div[class="selected"] > div { color: var(--ctp-mocha-text) !important; }
    .modal-dialog > .item-list > * { color: var(--ctp-mocha-text) !important; }
  '';

  xdg.configFile."joplin-desktop/userstyle.css".text = ''
    /* Catppuccin Mocha theme for Joplin - Rendered Markdown styling */
    /* Source: https://github.com/catppuccin/joplin */

    :root {
      --ctp-mocha-rosewater: #f5e0dc;
      --ctp-mocha-flamingo: #f2cdcd;
      --ctp-mocha-pink: #f5c2e7;
      --ctp-mocha-mauve: #cba6f7;
      --ctp-mocha-red: #f38ba8;
      --ctp-mocha-maroon: #eba0ac;
      --ctp-mocha-peach: #fab387;
      --ctp-mocha-yellow: #f9e2af;
      --ctp-mocha-green: #a6e3a1;
      --ctp-mocha-teal: #94e2d5;
      --ctp-mocha-sky: #89dceb;
      --ctp-mocha-sapphire: #74c7ec;
      --ctp-mocha-blue: #89b4fa;
      --ctp-mocha-lavender: #b4befe;
      --ctp-mocha-text: #cdd6f4;
      --ctp-mocha-subtext1: #bac2de;
      --ctp-mocha-subtext0: #a6adc8;
      --ctp-mocha-overlay2: #9399b2;
      --ctp-mocha-overlay1: #7f849c;
      --ctp-mocha-overlay0: #6c7086;
      --ctp-mocha-surface2: #585b70;
      --ctp-mocha-surface1: #45475a;
      --ctp-mocha-surface0: #313244;
      --ctp-mocha-base: #1e1e2e;
      --ctp-mocha-mantle: #181825;
      --ctp-mocha-crust: #11111b;
      --white: #D9E0EE;
      --black: #000000;
      --light: #C9CFFF;
      --font-face: "Inter", "Noto Sans", Arial, Helvetica, sans-serif;
      --font-mono: "JetBrainsMono Nerd Font", "Roboto Mono", Courier, monospace;
      --font-size: 13px;
      --regular: 400;
      --bolder: 600;
      --scroll-radius: 3px;
    }

    #rendered-md, body, th, td {
      background-color: var(--ctp-mocha-base) !important;
      font-family: var(--font-face) !important;
    }

    p, ul, ol, li { color: var(--ctp-mocha-text) !important; }
    strong { color: var(--ctp-mocha-text) !important; }

    hr {
      border: none;
      border-bottom: 1px solid var(--ctp-mocha-overlay1) !important;
      margin: 2.5em 0 !important;
    }

    ::-webkit-scrollbar-thumb {
      background-color: var(--ctp-mocha-base) !important;
      border-radius: var(--scroll-radius) !important;
    }

    /* Headings */
    h1 {
      color: var(--ctp-mocha-text);
      border-bottom: 1px solid var(--ctp-mocha-base) !important;
      font-weight: var(--bolder) !important;
    }

    h2, h3, h4, h5, h6 {
      color: var(--ctp-mocha-subtext1);
      border-bottom: 0 !important;
      font-weight: var(--regular) !important;
    }

    /* Links */
    a {
      color: var(--ctp-mocha-blue) !important;
      text-decoration: underline !important;
    }
    a:hover { text-decoration: underline !important; }
    .resource-icon { background-color: var(--ctp-mocha-rosewater) !important; }

    /* Code blocks */
    pre, .hljs {
      background-color: var(--ctp-mocha-mantle) !important;
      font-family: var(--font-mono) !important;
      padding: 10px !important;
      color: var(--ctp-mocha-text) !important;
      font-size: 14px !important;
      overflow: scroll !important;
    }

    .inline-code {
      background-color: transparent !important;
      border: 0 !important;
      font-family: var(--font-mono) !important;
      color: var(--ctp-mocha-yellow) !important;
      font-size: 14px !important;
    }

    /* Blockquotes */
    blockquote {
      background-color: var(--ctp-mocha-surface0) !important;
      padding: 10px !important;
      color: var(--light) !important;
      font-size: 14px !important;
      font-style: italic !important;
      border: 0 !important;
      border-left: 5px solid var(--ctp-mocha-mauve) !important;
    }

    /* Tables */
    th {
      border: 1px solid var(--ctp-mocha-text) !important;
      color: var(--ctp-mocha-text) !important;
      border-bottom: 1px solid var(--ctp-mocha-text) !important;
    }
    td {
      border: 1px solid var(--ctp-mocha-text) !important;
      color: var(--ctp-mocha-text) !important;
      border-bottom: 1px solid var(--ctp-mocha-text) !important;
    }

    /* Selection & highlighting */
    ::selection {
      background-color: var(--ctp-mocha-lavender) !important;
      color: var(--ctp-mocha-crust) !important;
    }

    mark, mark strong {
      background: var(--ctp-mocha-yellow) !important;
      color: var(--ctp-mocha-crust) !important;
    }

    mark[data-markjs] { background-color: var(--ctp-mocha-lavender) !important; }

    /* Spoiler plugin */
    .spoiler-block { border: 0 !important; border-radius: 0px; }
    #spoiler-block-title {
      font-family: var(--font-face) !important;
      color: var(--ctp-mocha-text) !important;
      background-color: var(--ctp-mocha-mantle) !important;
    }
    #spoiler-block-body {
      font-family: var(--font-face) !important;
      color: var(--light) !important;
      background-color: var(--ctp-mocha-mantle) !important;
    }
    .summary-content { background-color: var(--ctp-mocha-mantle) !important; }
    .summary-title:before { color: var(--ctp-mocha-mauve) !important; }

    /* Print version */
    @media print {
      #rendered-md, body, th, td {
        background-color: #ffffff !important;
        font-family: var(--font-face) !important;
      }
      p, ul, ol, li { color: var(--black) !important; }
      strong { color: var(--black) !important; }
      th, td {
        border: 1px solid var(--black) !important;
        color: var(--black) !important;
      }
      h1 {
        border-bottom: 1px solid var(--black) !important;
        font-weight: var(--bolder) !important;
      }
      h2, h3, h4, h5, h6 {
        border-bottom: 0 !important;
        font-weight: var(--bolder) !important;
      }
      hr {
        border: none;
        border-bottom: 1px solid var(--black) !important;
      }
      a { color: var(--ctp-mocha-red) !important; }
      .inline-code {
        background-color: #F8F8F8 !important;
        border: 0 !important;
      }
      pre, .hljs {
        background-color: #F8F8F8 !important;
        color: var(--ctp-mocha-crust) !important;
      }
      blockquote {
        background-color: #F8F8F8 !important;
        color: var(--ctp-mocha-crust) !important;
        border-left: 5px solid #E8E8E8 !important;
      }
    }
  '';
}
