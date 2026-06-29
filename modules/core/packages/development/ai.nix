{ pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs.llm-agents; [
      opencode
      pi
    ])
    ++ [
      pkgs.rtk
      pkgs.t3code
      pkgs.xdotool
    ];
}
