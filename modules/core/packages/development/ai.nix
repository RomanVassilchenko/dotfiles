{ pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs.llm-agents; [
      pi
    ])
    ++ [
      pkgs.rtk
      pkgs.t3code
      pkgs.terax-ai
      pkgs.xdotool
    ];
}
