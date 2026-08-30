{ config, pkgs, ... }:
{
  	programs.git = {
	  	settings = {
	    	user.name = "matty";
	    	user.email = "realkripper@email.com";
	    	init.defaultBranch = "main";
	  	};
  	};
}
