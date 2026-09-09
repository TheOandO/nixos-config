{ config, lib, pkgs, modulesPath, ... }:

{
  	imports = builtins.filter (f: lib.hasSuffix ".nix" f) (
    	lib.filesystem.listFilesRecursive ./containers
  	);

	environment = {
		systemPackages = [ pkgs.libheif pkgs.libheif.out ];
		pathsToLink = [ 
				"/share/thumbnailers"
				"/share/applications"
				"/share/icons"
				"/share/mime"
				"/etc/xdg"
		];
		sessionVariables = {
			XDG_MENU_PREFIX = "plasma-";
		};
	};

	services = {
		pipewire = {
			enable = true;
			wireplumber = {
				enable = true;
				extraConfig = {
					"10-disable-suspend" = {
						"monitor.alsa.rules" = [
						{
							matches = [ { "node.name" = "~alsa_output.*"; } ];
							actions = {
								"update-props" = {
									"session.suspend-timeout-seconds" = 0;
								};
							};
						}];
					};
					"51-disable-suspend" = {
						"wireplumber.settings" = {
							"node.suspend-timeout-seconds" = 0;
						};
					};
				};
			};
		};

		lact.enable = true;

		scx = {
			scheduler = "scx_cosmos";
			extraArgs = [];
		};

		sunshine = {
			enable = true;
			autoStart = false;
			capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
			openFirewall = true;
		};

		desktopManager.plasma6.enable = true;
	};
}
