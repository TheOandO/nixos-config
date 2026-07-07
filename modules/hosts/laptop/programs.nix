{ config, pkgs, inputs, ... }:

{
 	# List packages installed in system profile. To search, run:
  	# $ nix search wget
  	environment.systemPackages = with pkgs; [
    	gnome-text-editor
    	nautilus
		vscodium
		gparted
		#Icon theme
		papirus-icon-theme
	];

	# Some programs need SUID wrappers, can be configured further or are
  	# started in user sessions.

  	programs.niri.enable = true;

	programs.nautilus-open-any-terminal.enable = true;
	programs.dconf.enable = true;
}
