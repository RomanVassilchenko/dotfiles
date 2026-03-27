{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ctop # Container metrics and monitoring
    dive # Analyze Docker image layers
    # k9s # Kubernetes TUI
  ];
}
