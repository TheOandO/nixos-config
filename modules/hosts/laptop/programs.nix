{ config, pkgs, inputs, ... }:

{
 	# List packages installed in system profile. To search, run:
  	# $ nix search wget
  	environment.systemPackages = with pkgs; [
	    gnome-text-editor
	    eog
		nautilus
		vscodium
		gparted
		adwaita-qt
		adw-gtk3
		gnome-themes-extra
		gsettings-desktop-schemas
		gnome-keyring
		glib
		gedit
		polkit_gnome
		zoom-us
		moonlight-qt
		appimage-run
		file-roller

		#Icon theme
		papirus-icon-theme
		
	];

	nixpkgs.config.packageOverrides = pkgs: {
		intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
	};
	# Some programs need SUID wrappers, can be configured further or are
  	# started in user sessions.

	programs = {
		niri.enable = true;
		nautilus-open-any-terminal.enable = true;
		dconf.enable = true;

		appimage = {
			enable = true;
			binfmt = true;
			package = pkgs.appimage-run.override
			{
				extraPkgs = pkgs:
				[
					pkgs.icu
					pkgs.libxcrypt-legacy
					# pkgs.python312
					# pkgs.python312Packages.torch
				];
			};
		};
	};
}

