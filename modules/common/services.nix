{ config, lib, pkgs, modulesPath, ... }:
{
	services = {
		# X11 keymap
		xserver.xkb = {
			layout = "us";
			variant = "";
		};

		# List services that you want to enable:
		displayManager = {
			sddm = {
				enable = true;

				wayland = {
					enable = true;
				};
			};

			autoLogin = {
				enable = false;
				user = "matty";
			};
		};

		# Enable the OpenSSH daemon.
		openssh.enable = true;

		gvfs.enable = true;

		# Power profiles daemon
		power-profiles-daemon.enable = true;
		upower.enable = true;

		tailscale = {
			enable = true;
			# Enable tailscale at startup
			#authKeyFile = "/run/secrets/tailscale_key";

		};

		avahi = {
			enable = true;
			nssmdns4 = true;
			openFirewall = true;
		};

		syncthing = {
			enable = true;
			openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
			user = "matty";
			dataDir = "/home/matty";
			configDir = "/home/matty/.config/syncthing";
		};

		samba = {
			package = pkgs.samba4Full;
			usershares.enable = true;
			enable = false;
			openFirewall = true;
		};

		# Required for Nautilus to discover shares on the network
		samba-wsdd = {
			enable = false;
			openFirewall = true;
		};

		scx = {
			enable = true;
			package = pkgs.scx.rustscheds;
			# - scx_bpfland: good for responsive desktop under heavy background load
			# - scx_lavd: built for the Steam Deck to eliminate gaming micro-stutter
			# - scx_cosmos: good desktop and server default, less battle-tested?
			# scheduler = "scx_cake";
			# extraArgs = [ ];
		};

	};

	hardware.uinput.enable = true;
}
