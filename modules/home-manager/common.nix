{ config, pkgs, ... }:
{
  	home.username = "matty";
  	home.homeDirectory = "/home/matty";
  	home.stateVersion = "24.11";

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
