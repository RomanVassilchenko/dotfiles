{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    configPackages = [ pkgs.kdePackages.plasma-desktop ];
  };
  services = {
    flatpak = {
      enable = true;

      # List the Flatpak applications you want to install
      # Use the official Flatpak application ID (e.g., from flathub.org)
      # Examples:
      packages = [
        "com.github.tchx84.Flatseal" # Manage flatpak permissions - should always have this
        "com.rtosta.zapzap" # WhatsApp client
        "io.github.dvlv.boxbuddyrs" # Manage distroboxes
        "io.github.flattool.Warehouse" # Manage flatpaks, clean data, remove flatpaks and deps
        "it.mijorus.gearlever" # Manage and support AppImages
        #"io.github.freedoom.Phase1"      #  Classic Doom FPS 1
        #"io.github.freedoom.Phase2"      #  Classic Doom FPS 2
        #"io.github.dvlv.boxbuddyrs"      #  Manage distroboxes
        #"de.schmidhuberj.tubefeeder"     #watch YT videos

        # Add other Flatpak IDs here, e.g., "org.mozilla.firefox"
      ];

      # Don't update flatpaks during boot - it blocks for 50+ minutes
      # Run `flatpak update` manually or set up a timer
      update.onActivation = false;
    };
  };
}
