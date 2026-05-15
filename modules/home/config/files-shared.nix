{
  config,
  dotfiles,
  ...
}:
let
  dotfilesPath = dotfiles.paths.dotfiles;
  publicConfig = "${dotfilesPath}/config";
  privateConfig = "${dotfilesPath}/private/home/config";
  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  inherit
    dotfilesPath
    publicConfig
    privateConfig
    outOfStore
    ;
}
