{ config, lib, pkgs, modulesPath, ... }:
{
# 	systemd.user.services.niri.enableDefaultPath = false;
	services  = {
		gnome.gnome-keyring.enable = true;

		scx = {
			# - scx_bpfland: good for responsive desktop under heavy background load
			# - scx_lavd: built for the Steam Deck to eliminate gaming micro-stutter
			# - scx_cosmos: good desktop and server default, less battle-tested?
			scheduler = "scx_bpfland";
			extraArgs = [ ];
		};
	};

	environment = {
		systemPackages = [ pkgs.libheif pkgs.libheif.out ];
		pathsToLink = [ "share/thumbnailers" ];
	};
}
