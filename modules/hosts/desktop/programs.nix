{ config, pkgs, inputs, ... }:
{
	environment.systemPackages = with pkgs; [
		  kdePackages.dolphin
		  kdePackages.ark
		  kdePackages.kate
		  kdePackages.gwenview
	];

	programs.hyprland.enable = true;
	programs.dms-shell = {
	  	enable = true;

		quickshell.package = pkgs.quickshell;
		
		# Core features
		enableSystemMonitoring = true;     # System monitoring widgets (dgop)
		enableVPN = true;                  # VPN management widget
		enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
		enableAudioWavelength = true;      # Audio visualizer (cava)
		enableCalendarEvents = true;       # Calendar integration (khal)
		enableClipboardPaste = true;       # Pasting from the clipboard history (wtype)
	};
	
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
}
