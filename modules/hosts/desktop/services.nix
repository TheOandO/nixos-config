{ config, lib, pkgs, modulesPath, ... }:
{
	environment.systemPackages = [ pkgs.libheif pkgs.libheif.out ];
	environment.pathsToLink = [ "share/thumbnailers" ];
}
