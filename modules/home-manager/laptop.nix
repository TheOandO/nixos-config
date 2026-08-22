{ config, pkgs, ... }:
{
	# xdg.configFile."niri/config.kdl".source = ./config.kdl;
	
	gtk = {
		enable = true;
		iconTheme = {
			name = "Papirus-Dark";
		    package = pkgs.papirus-icon-theme;
		};
		gtk3.extraConfig = {
		    gtk-application-prefer-dark-theme = 1;
			gtk-theme-name = "Adwaita";
		};
		gtk4.extraConfig = {
		    gtk-application-prefer-dark-theme = 1;
		    gtk-theme-name = "Adwaita";
		};
	};

	dconf.settings = {
	  	"org/gnome/desktop/interface" = {
	    	color-scheme = "prefer-dark";
	    	gtk-theme = "Adwaita";
	  	};
	};

	home.sessionVariables = {
		GTK_THEME = "Adwaita";
		GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
	};




	programs.fish.functions = {
		rebuild = ''
			  	cd /etc/nixos
			  	sudo nix flake update
			  	sudo git add .
			  	read -P "Commit message (leave empty for default): " msg
			  	if test -z "$msg"
			    	set msg "update: "(date +%Y-%m-%d)
			  	end
			  	sudo git commit -m "$msg"; or true
				sudo git fetch origin
				sudo git rebase -X ours origin/main; or true
				sudo git push --force
			  	sudo nixos-rebuild switch --upgrade-all --flake .#laptop
		'';
		pull-nix = ''
		        cd /etc/nixos
		        sudo git stash
		        sudo git pull
		        sudo git stash clear
		        sudo nixos-rebuild switch --upgrade-all --flake .#laptop
		'';
		pull-dot = ''
		        cd ~/.config
		        sudo git stash
		        sudo git pull
		        sudo git stash clear
		'';
	};
}
