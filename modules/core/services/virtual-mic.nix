{ config, lib, ... }:
lib.mkIf config.dotfiles.features.desktop.enable {
  services.pipewire.extraConfig.pipewire."10-virtual-mic" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "VirtualMic";
          "node.description" = "Virtual Microphone";
          "media.class" = "Audio/Duplex";
          "audio.position" = "FL,FR";
          "monitor.passthrough" = true;
        };
      }
    ];
  };
}
