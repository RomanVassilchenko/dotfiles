{ ... }:
{
  xdg.dataFile."konsole/catppuccin-mocha.colorscheme".text = ''
    [Background]
    Color=30,30,46

    [BackgroundFaint]
    Color=24,24,37

    [BackgroundIntense]
    Color=49,50,68

    [Color0]
    Color=69,71,90

    [Color0Faint]
    Color=69,71,90

    [Color0Intense]
    Color=88,91,112

    [Color1]
    Color=243,139,168

    [Color1Faint]
    Color=243,139,168

    [Color1Intense]
    Color=243,139,168

    [Color2]
    Color=166,227,161

    [Color2Faint]
    Color=166,227,161

    [Color2Intense]
    Color=166,227,161

    [Color3]
    Color=249,226,175

    [Color3Faint]
    Color=249,226,175

    [Color3Intense]
    Color=249,226,175

    [Color4]
    Color=137,180,250

    [Color4Faint]
    Color=137,180,250

    [Color4Intense]
    Color=137,180,250

    [Color5]
    Color=203,166,247

    [Color5Faint]
    Color=203,166,247

    [Color5Intense]
    Color=245,194,231

    [Color6]
    Color=148,226,213

    [Color6Faint]
    Color=148,226,213

    [Color6Intense]
    Color=148,226,213

    [Color7]
    Color=186,194,222

    [Color7Faint]
    Color=186,194,222

    [Color7Intense]
    Color=166,173,200

    [Foreground]
    Color=205,214,244

    [ForegroundFaint]
    Color=166,173,200

    [ForegroundIntense]
    Color=205,214,244

    [General]
    Blur=true
    ColorRandomization=false
    Description=Catppuccin Mocha
    Opacity=0.92
    Wallpaper=
  '';

  # Full reproduction of the embedded "Linux console" keytab with one override:
  # Shift+Return sends \r\n for multiline input in Claude Code, OpenCode, and other modern CLIs.
  # Default Konsole sends \EOM (VT100 numeric keypad Enter, 1978) which modern apps ignore.
  # See: https://github.com/anthropics/claude-code/issues/2115
  # IMPORTANT: Return+Shift must come before Return-NewLine — first match wins.
  xdg.dataFile."konsole/custom.keytab".text = ''
    keyboard "custom"

    key Return+Shift   : "\r\n"

    key Escape         : "\E"
    key Tab            : "\t"
    key Return-NewLine : "\r"
    key Return+NewLine : "\r\n"

    key Backspace      : "\x7f"
    key Delete         : "\E[3~"

    key Up   -Shift-Ansi : "\EA"
    key Down -Shift-Ansi : "\EB"
    key Right-Shift-Ansi : "\EC"
    key Left -Shift-Ansi : "\ED"

    key Up   -Shift+Ansi+AppCuKeys : "\EOA"
    key Down -Shift+Ansi+AppCuKeys : "\EOB"
    key Right-Shift+Ansi+AppCuKeys : "\EOC"
    key Left -Shift+Ansi+AppCuKeys : "\EOD"
    key Up   -Shift+Ansi-AppCuKeys : "\E[A"
    key Down -Shift+Ansi-AppCuKeys : "\E[B"
    key Right-Shift+Ansi-AppCuKeys : "\E[C"
    key Left -Shift+Ansi-AppCuKeys : "\E[D"

    key F1  : "\E[[A"
    key F2  : "\E[[B"
    key F3  : "\E[[C"
    key F4  : "\E[[D"
    key F5  : "\E[[E"
    key F6  : "\E[17~"
    key F7  : "\E[18~"
    key F8  : "\E[19~"
    key F9  : "\E[20~"
    key F10 : "\E[21~"
    key F11 : "\E[23~"
    key F12 : "\E[24~"

    key Home   : "\E[1~"
    key End    : "\E[4~"
    key PgUp   -Shift : "\E[5~"
    key PgDown -Shift : "\E[6~"
    key Insert -Shift : "\E[2~"

    key Enter+NewLine : "\r\n"
    key Enter-NewLine : "\r"

    key Space +Control : "\x00"

    key Up     +Shift       : scrollLineUp
    key PgUp   +Shift-Ctrl  : scrollPageUp
    key PgUp   +Shift+Ctrl  : scrollPromptUp
    key Down   +Shift       : scrollLineDown
    key PgDown +Shift-Ctrl  : scrollPageDown
    key PgDown +Shift+Ctrl  : scrollPromptDown
  '';

  programs.konsole = {
    enable = true;
    defaultProfile = "default";
    profiles.default = {
      name = "default";
      colorScheme = "catppuccin-mocha";
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      extraConfig = {
        Keyboard.KeyBindings = "custom";
        Cursor = {
          CursorShape = 0; # Block
          BlinkingCursorEnabled = true;
        };
        Scrolling = {
          HistorySize = 10000;
          ScrollBarPosition = 2; # Hidden
        };
        Appearance = {
          BoldIntense = false;
        };
      };
    };
    extraConfig = {
      KonsoleWindow = {
        ShowMenuBarByDefault = false;
        RememberWindowSize = false;
        RemoveWindowTitleBarAndFrame = true;
      };
      "MainWindow".ToolBarsMovable = "Disabled";
      TabBar = {
        TabBarVisibility = 1; # 0=AlwaysShow, 1=ShowWhenNeeded, 2=AlwaysHide
        ShowQuickButtons = false;
        NewTabButton = false;
        CloseTabButton = false;
      };
    };
  };
}
