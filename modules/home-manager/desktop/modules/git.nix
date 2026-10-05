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
			key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdiV0z7ZHR+rSEGydRa2rFOWUCGV5y7NnKxrK41R8KC realkripper@gmail.com";
			signByDefault = true;
		};
  	};
}

