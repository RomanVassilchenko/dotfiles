{ pkgs-stable, ... }:
{
  programs.btop = {
    enable = true;
    package = pkgs-stable.btop;
    settings = {
      vim_keys = false;
      rounded_corners = true;
      proc_tree = true;
      proc_gradient = false;
      show_gpu_info = "on";
      show_uptime = true;
      show_coretemp = true;
      cpu_sensor = "auto";
      show_disks = true;
      only_physical = true;
      io_mode = true;
      io_graph_combined = false;
      update_ms = 1000;
      theme_background = false;
    };
  };
}
