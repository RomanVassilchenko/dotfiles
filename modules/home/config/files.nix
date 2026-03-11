{ config, ... }:
let
  dotfilesPath = "/home/romanv/Documents/dotfiles";
in
{
  home.file = {
    ".ssh/id_personal" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ssh/id_personal";
    };
    ".ssh/id_personal.pub" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ssh/id_personal.pub";
    };
    ".ssh/id_xiaoxinpro_work" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ssh/id_xiaoxinpro_work";
    };
    ".ssh/id_xiaoxinpro_work.pub" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ssh/id_xiaoxinpro_work.pub";
    };
    ".claude" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/.claude";
    };
  };
}
