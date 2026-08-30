{ lib, ... }:
let
    # everything in this directory
    entries = builtins.readDir ./.;

    # .nix files other than this one
    isNixFile = name: type:
        type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";

    # subdirectories (each needs its own default.nix to be importable this way)
    isDir = name: type: type == "directory";

    nixFiles = lib.mapAttrsToList (name: _: ./. + "/${name}")
        (lib.filterAttrs isNixFile entries);

    subDirs = lib.mapAttrsToList (name: _: ./. + "/${name}")
        (lib.filterAttrs isDir entries);
in
{
    imports = nixFiles ++ subDirs;
}
