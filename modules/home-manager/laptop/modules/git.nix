{ config, pkgs, ... }:
{
  	programs.git = {
	  	settings = {
			user.name = "matty";
		    	user.email = "realkripper@email.com";
		    	init.defaultBranch = "main";
		    	gpg = {
				format = "ssh";
		      	};
	  	};
	  	signing = {
		      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8zAYOrlwjR4JDuGc/SVytHzYPpWgUHSjWwpTI8oCs2 realkripper@email.com";
		      signByDefault = true;
		};
  	};
}
