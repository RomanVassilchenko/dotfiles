{ ... }:
{
  services.flatpak = {
    enable = true;

    packages = [ ];

    update.onActivation = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
