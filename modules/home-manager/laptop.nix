{ config, pkgs, ... }:
{
	# xdg.configFile."niri/config.kdl".source = ./config.kdl;
	gtk = {
		enable = true;
		iconTheme = {
			name = "Papirus-Dark";
		    package = pkgs.papirus-icon-theme;
		};
  		gtk3 = {
    		extraConfig = {
      			gtk-application-prefer-dark-theme = 1;
      			gtk-theme-name = "adw-gtk3-dark";
    		};
  		};
	};

	qt = {
	    enable = true;
		platformTheme.name = "Adwaita-dark";
	    style = {
	      	name = "Adwaita-dark";
	      	package = pkgs.adwaita-qt;
	    };
	};
	
	xdg.portal = {
	    enable = true;
	    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
	    config.common.default = "gtk";
	};

	systemd.user.services.polkit-gnome-authentication-agent-1 = {
	  	Unit = {
	    	Description = "polkit-gnome-authentication-agent-1";
	    	Wants = [ "graphical-session.target" ];
	    	After = [ "graphical-session.target" ];
	  	};
	  	Install = {
	    	WantedBy = [ "graphical-session.target" ];
	  	};
	  	Service = {
	    	Type = "simple";
	    	ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
	    	Restart = "on-failure";
	    	RestartSec = 1;
	    	TimeoutStopSec = 10;
	  	};
	};

	programs = {
		noctalia = {
			settings = "~/.config/noctalia/noctalia-config.toml";
		};	
	};

}
