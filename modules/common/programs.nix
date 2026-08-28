{ config, pkgs, inputs, ... }:

{
 	# List packages installed in system profile. To search, run:
  	# $ nix search wget
  	environment.systemPackages = with pkgs; [
  		#  vim # Do not forget to add an editor to edit configuration.nix! The Nano edito>
	    	wget
	    	btop
	    	xwayland-satellite
	    	fastfetch
	    	kitty
	   	micro
		gtk4
		git
		wev
		glib
		sbctl
		nwg-look
			
		pear-desktop
		inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
		inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
		vesktop
		vscode-fhs
		libreoffice-stable
		obsidian
		gparted
		qbittorrent

	    	inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.default
		inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default
					
		# Fish shell plugins
	    	fishPlugins.tide
	    	fishPlugins.done
	    	fishPlugins.fzf-fish
	    	fzf
	    	fishPlugins.grc
	    	grc

		lsfg-vk
		lsfg-vk-ui
		heroic
		protonplus
		goverlay
		mangohud    	
	];

	programs = {
		# Some programs need SUID wrappers, can be configured further or are
		# started in user sessions.
		mtr.enable = true;
		gnupg.agent = {
    		enable = true;
    		enableSSHSupport = true;
		};

		fish.enable = true;
		firefox.enable = true;

		dconf.profiles.user.databases = [
		{
			settings."org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
			};
		}];

		steam = {
			enable = true; # Master switch, already covered in in>
			remotePlay.openFirewall = true;  # Open ports in the >
			dedicatedServer.openFirewall = true; # Open ports for>
		};
		gamemode.enable = true;
	};
}
