{ config, lib, pkgs, modulesPath, ... }:
{
	services.gnome.gnome-keyring.enable = true;
	systemd.user.services.niri.enableDefaultPath = false;

	services.scx = {
	  # - scx_bpfland: good for responsive desktop under heavy background load
	  # - scx_lavd: built for the Steam Deck to eliminate gaming micro-stutter
	  # - scx_cosmos: good desktop and server default, less battle-tested?
	  scheduler = "scx_bpfland";
	  extraArgs = [ ];
	};
	
	systemd.user.services.polkit-gnome-authentication-agent-1 = {
	  	description = "polkit-gnome-authentication-agent-1";
	  	wantedBy = [ "graphical-session.target" ];
	  	wants = [ "graphical-session.target" ];
	  	after = [ "graphical-session.target" ];
	  	serviceConfig = {
	    	Type = "simple";
	    	ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
	    	Restart = "on-failure";
	    	RestartSec = 1;
	    	TimeoutStopSec = 10;
	  	};
	};
	
	environment.systemPackages = [ pkgs.libheif pkgs.libheif.out ];
	environment.pathsToLink = [ "share/thumbnailers" ];
}
