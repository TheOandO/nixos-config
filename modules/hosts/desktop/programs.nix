{ config, pkgs, inputs, ... }:
{
	environment.systemPackages = with pkgs; [
		kdePackages.dolphin
		kdePackages.ark
		kdePackages.kate
		kdePackages.gwenview
		kdePackages.qtsvg
		kdePackages.kio # needed since 25.11
		kdePackages.kio-fuse #to mount remote filesystems via FUSE
		kdePackages.kio-extras #extra protocols support (sftp, fish and more)
		kdePackages.kservice
		kdePackages.qtsvg 
		libsForQt5.qt5ct
		kdePackages.qt6ct
		kdePackages.plasma-workspace
		desktop-file-utils
  		xdg-utils
		kdePackages.kde-cli-tools
		
		heroic
		protonplus
	];

	programs.hyprland.enable = true;

	programs.dconf.profiles.user.databases = [
		{
	    	settings."org/gnome/desktop/interface" = {
		        gtk-theme = "Adwaita";
		        icon-theme = "Flat-Remix-Red-Dark";
		        font-name = "Noto Sans Medium 11";
		        document-font-name = "Noto Sans Medium 11";
		        monospace-font-name = "Noto Sans Mono Medium 11";
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
