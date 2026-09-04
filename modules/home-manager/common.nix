{ config, pkgs, ... }:
{
	imports = [
		./modules
	];

  	home = {
		username = "matty";
		homeDirectory = "/home/matty";
		stateVersion = "24.11";
		pointerCursor = {
			enable = true;
			gtk.enable = true;
			x11.enable = true;
			package = pkgs.bibata-cursors;
			name = "Bibata-Modern-Classic";
			size = 18;
		};
  	};

	xdg = {
		userDirs = {
			enable = true;
			setSessionVariables = false;
		};
	};

	dconf = {
		enable = true;
		settings = {
			"org/gnome/desktop/interface" = {
		    	color-scheme = "prefer-dark";
		    };
		};
	};

	home-manager.users.username.services.kdeconnect.enable = true;
	
	networking.firewall = rec {
	  	allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
	  	allowedUDPPortRanges = allowedTCPPortRanges;
	};
}
