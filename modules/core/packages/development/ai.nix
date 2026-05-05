{ pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs.llm-agents; [
      opencode
      pi
    ])
    ++ [
      pkgs.rtk
      pkgs.xdotool
    ];
}
