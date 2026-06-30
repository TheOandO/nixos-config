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
    	obsidian
		gtk4
		libreoffice-fresh
		github-desktop
		git
		gparted
		wev
		glib
		gedit

		pear-desktop
		inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
		inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
		
		vesktop
		
		# Fish shell plugins
    	fishPlugins.tide
    	fishPlugins.done
    	fishPlugins.fzf-fish
    	fzf
    	fishPlugins.grc
    	grc

	];

	# Some programs need SUID wrappers, can be configured further or are
  	# started in user sessions.
  	programs.mtr.enable = true;
  	programs.gnupg.agent = {
    		enable = true;
    		enableSSHSupport = true;
  	};

  	programs.fish.enable = true;
 	programs.firefox.enable = true;

	programs.dconf.enable = true;
}
