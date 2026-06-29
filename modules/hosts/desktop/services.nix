{ config, lib, pkgs, modulesPath, ... }:
{
	environment.systemPackages = [ pkgs.libheif pkgs.libheif.out ];
	environment.pathsToLink = [ 
		"/share/thumbnailers"
		"/share/applications"
		"/share/icons"
		"/share/mime"
		"/etc/xdg"
	];
	environment.sessionVariables = {
		XDG_MENU_PREFIX = "plasma-";
		QT_QPA_PLATFORMTHEME = "kde";
	};
	
}
