{ config, lib, pkgs, modulesPath, ... }:

{
  imports = builtins.filter (f: lib.hasSuffix ".nix" f) (
    lib.filesystem.listFilesRecursive ./containers
  );

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
	};

	services.pipewire = {
	  enable = true;
	  wireplumber.enable = true;
	  wireplumber.extraConfig = {
	    "10-disable-suspend" = {
	      "monitor.alsa.rules" = [
	        {
	          matches = [ { "node.name" = "~alsa_output.*"; } ];
	          actions = {
	            "update-props" = {
	              "session.suspend-timeout-seconds" = -1;
	            };
	          };
	        }
	      ];
	    };
	  };
	};

	services.lact.enable = true;
}
