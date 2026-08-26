{ config, pkgs, inputs, ... }:

{
 	# List packages installed in system profile. To search, run:
  	# $ nix search wget
  	environment.systemPackages = with pkgs; [
    	gnome-text-editor
    	nautilus
		vscodium
		gparted
		adwaita-qt
		gnome-themes-extra
		gsettings-desktop-schemas
		glib
		gedit
		
		#Icon theme
		papirus-icon-theme

        inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli
	];

	# Some programs need SUID wrappers, can be configured further or are
  	# started in user sessions.

	programs = {
		hyprland.enable = true;
		nautilus-open-any-terminal.enable = true;
		dconf.enable = true;
	};
}

