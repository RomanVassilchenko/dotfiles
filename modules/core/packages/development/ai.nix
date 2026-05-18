{ pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs.llm-agents; [
      pi
    ])
    ++ [
      pkgs.rtk
      pkgs.xdotool
    ];
}
