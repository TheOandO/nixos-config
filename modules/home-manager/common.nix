{ config, pkgs, ... }:
{
	imports = [
		./modules/fish/fish-functions.nix
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

  	programs.git = {
	  	settings = {
	    	user.name = "matty";
	    	user.email = "realkripper@email.com";
	    	init.defaultBranch = "main";
	  	};
  	};

  	programs.fish = {
		interactiveShellInit = ''
 	    	fastfetch
 	    	set fish_greeting ""
		'';
  	};
}
