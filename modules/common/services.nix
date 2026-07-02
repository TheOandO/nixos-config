{ config, lib, pkgs, modulesPath, ... }:
{
	# X11 keymap
	services.xserver.xkb = {
		layout = "us";
		variant = "";
	};

	# List services that you want to enable:
    services.displayManager = {
    	sddm.enable = true;

        sddm.wayland = {
        	enable = true;
        };
        autoLogin = {
            enable = true;
            user = "matty";
        };
     };

	# Enable the OpenSSH daemon.
    services.openssh.enable = true;
	
	# Power profiles daemon
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

	services.tailscale = {
		enable = true;
		# Enable tailscale at startup
		#authKeyFile = "/run/secrets/tailscale_key";

	};

	services.avahi = {
		enable = true;
		nssmdns4 = true;
		openFirewall = true;
	};

	services.syncthing = {
	  	enable = true;
	  	openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
		user = "matty";
		dataDir = "/home/matty";
		configDir = "/home/matty/.config/syncthing";
	};

	services.samba = {
	    package = pkgs.samba4Full;
	    usershares.enable = true;
	    enable = true;
	    openFirewall = true;
	};

	# Required for Nautilus to discover shares on the network
	services.samba-wsdd = {
		enable = true;
		openFirewall = true;
	};

	services.scx = {
		  enable = true;
		  package = pkgs.scx.rustscheds;
		  # - scx_bpfland: good for responsive desktop under heavy background load
		  # - scx_lavd: built for the Steam Deck to eliminate gaming micro-stutter
		  # - scx_cosmos: good desktop and server default, less battle-tested?
		  scheduler = "scx_lavd";
		  extraArgs = [ ];
	};

	systemd.services.git-pull-config = {
		  description = "Pull latest NixOS config from GitHub on boot";
		  after = [ "network-online.target" ];
		  wants = [ "network-online.target" ];
		  wantedBy = [ "multi-user.target" ];
		  restartIfChanged = false;
		  serviceConfig = {
			    Type = "oneshot";
			    RemainAfterExit = true;
			    ExecStart = pkgs.writeShellScript "git-pull-config" ''
				      cd /etc/nixos
				      ${pkgs.git}/bin/git stash
				      ${pkgs.git}/bin/git pull --rebase
				      ${pkgs.git}/bin/git stash pop || true
			    '';
			    User = "root";
		  };
	};
}
