{ config, pkgs, inputs, ... }:
{
	environment.systemPackages = with pkgs; [
		kdePackages.dolphin
		kdePackages.ark
		kdePackages.kate		
		kdePackages.ktexteditor
		kdePackages.gwenview
		kdePackages.qtsvg
		kdePackages.kio
		kdePackages.kio-fuse
		kdePackages.kio-extras
		kdePackages.kio-admin
		kdePackages.kservice
		kdePackages.qtsvg 
		kdePackages.qtwayland
		kdePackages.kcoreaddons
		kdePackages.kiconthemes
		kdePackages.dolphin-plugins
		kdePackages.spectacle
		kdePackages.ffmpegthumbs
		kdePackages.krdp
		kdePackages.kimageformats # provides Qt plugins
		kdePackages.qtimageformats # provides optional image formats such as .webp and .avif
		kdePackages.kfilemetadata
		libsForQt5.qt5ct
		kdePackages.qt6ct
		kdePackages.plasma-workspace
		desktop-file-utils
  		xdg-utils
		kdePackages.kde-cli-tools

		nordic
		kdePackages.qtstyleplugin-kvantum
		libsForQt5.qtstyleplugin-kvantum
		
		lsfg-vk
		lsfg-vk-ui
		heroic
		protonplus
		goverlay
		mangohud
	];

	programs.hyprland.enable = true;

	programs.dconf.profiles.user.databases = [
		{
	    	settings."org/gnome/desktop/interface" = {
	    		color-scheme = "prefer-dark";
	    	};
	    }
	];

	programs.steam = {
	  enable = true; # Master switch, already covered in installation
	  remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
	  dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
	  # Other general flags if available can be set here.
	};

	programs.gamemode.enable = true;
	
}
