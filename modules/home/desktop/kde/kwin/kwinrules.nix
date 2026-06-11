{
  kwinrulesrc = {
    "1" = {
      Description = "Hide titlebar by default";
      noborder = true;
      noborderrule = 3;
      wmclass = ".*";
      wmclasscomplete = true;
      wmclassmatch = 3;
    };

    "2" = {
      Description = "Web to Desktop 1";
      desktops = "Desktop_1";
      desktopsrule = 3;
      types = 1;
      wmclass = "helium|google-chrome|xfreerdp";
      wmclasscomplete = false;
      wmclassmatch = 3;
    };

    "3" = {
      Description = "Terminals to Desktop 2";
      desktops = "Desktop_2";
      desktopsrule = 3;
      types = 1;
      wmclass = "kitty";
      wmclasscomplete = false;
      wmclassmatch = 3;
    };

    "4" = {
      Description = "Dev to Desktop 3";
      desktops = "Desktop_3";
      desktopsrule = 3;
      types = 1;
      wmclass = "code|Code|code-url-handler|Zed|dev.zed.Zed|camunda-modeler|DBeaver|Postman|com.obsproject.Studio";
      wmclasscomplete = false;
      wmclassmatch = 3;
    };

    "5" = {
      Description = "Chat to Desktop 4";
      desktops = "Desktop_4";
      desktopsrule = 3;
      types = 1;
      wmclass = "org.telegram.desktop|TelegramDesktop|com.rtosta.zapzap|zapzap|vesktop|zoom.*|obsidian";
      wmclasscomplete = false;
      wmclassmatch = 3;
    };

    "6" = {
      Description = "Play to Desktop 5";
      desktops = "Desktop_5";
      desktopsrule = 3;
      types = 1;
      wmclass = "osu!|prismlauncher|steam|Steam|Minecraft";
      wmclasscomplete = false;
      wmclassmatch = 3;
    };

    "11" = {
      Description = "Picture-in-Picture: Float, Always On Top";
      above = true;
      aboverule = 2;
      desktops = "";
      desktopsrule = 2;
      floatrule = 2;
      ignoregeometry = false;
      ignoregeometryrule = 2;
      position = "1920,1080";
      positionrule = 3;
      size = "640,360";
      sizerule = 3;
      skipagerrule = 2;
      skippager = true;
      skiptaskbar = true;
      skiptaskbarrule = 2;
      title = "Picture in picture";
      titlematch = 2;
      types = 1;
      wmclass = "helium";
      wmclassmatch = 3;
    };

    General = {
      count = 7;
      rules = "1,2,3,4,5,6,11";
    };
  };
}
