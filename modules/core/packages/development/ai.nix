{ pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs.llm-agents; [
      claude-code
      codex
      gemini-cli
      opencode
      pi
    ])
    ++ [
      pkgs.rtk
    ];
}
