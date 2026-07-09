{ config, pkgs, ... }:
{
	home.pointerCursor = {
		enable = true;
		gtk.enable = true;
		x11.enable = true;
		package = pkgs.bibata-cursors;
		name = "Bibata-Modern-Classic";
		size = 18;
	};

	qt = {
		enable = true;
	};

	# gtk = {
	# 	enable = true;
	# 	iconTheme = {
	# 		name = "Nordic-green";
	#   };
	# };

	xdg.mimeApps = {
	  enable = true;
	  defaultApplications = {
	    "inode/directory" = "org.kde.dolphin.desktop";
	    "text/html" = "zen.desktop";
	    "x-scheme-handler/http" = "zen.desktop";
	    "x-scheme-handler/https" = "zen.desktop";
	    "x-scheme-handler/ftp" = "zen.desktop";
	    "application/xhtml+xml" = "zen.desktop";
	    "application/x-extension-htm" = "zen.desktop";
	    "application/x-extension-html" = "zen.desktop";
	    "application/x-extension-xhtml" = "zen.desktop";
	  };
	};
	
	programs.fish.functions.rebuild = ''
		cd /etc/nixos
		sudo git add .
		read -P "Commit message (leave empty for default): " msg
		if test -z "$msg"
		    set msg "update: "(date +%Y-%m-%d)
		end
		sudo git commit -m "$msg"; or true
		sudo git fetch origin
		sudo git rebase -X ours origin/main; or true
		sudo git push --force
		sudo nix flake update
	  	sudo nixos-rebuild switch --upgrade-all --flake .#desktop
	'';
}
