{ config, pkgs, ... }:
{
  	home.username = "matty";
  	home.homeDirectory = "/home/matty";
  	home.stateVersion = "24.11";

    home.pointerCursor = {
    	enable = true;
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 18;
    };

	xdg.userDirs.enable = true;
	xdg.userDirs.setSessionVariables = false;
	

  	programs.git = {
  	  	enable = true;
	  	settings = {
	    	user.name = "matty";
	    	user.email = "realkripper@email.com";
	    	init.defaultBranch = "main";
	  	};
  	};

  	programs.fish = {
  	  	enable = true;

		interactiveShellInit = ''
 	    	fastfetch
 	    	set fish_greeting ""
		'';
  	};
}
