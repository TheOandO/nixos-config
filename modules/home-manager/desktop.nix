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
    		# Directories
    		"inode/directory" = "org.kde.dolphin.desktop";
    
    		# Browser
    		"text/html" = "zen.desktop";
    		"x-scheme-handler/http" = "zen.desktop";
    		"x-scheme-handler/https" = "zen.desktop";
    		"application/xhtml+xml" = "zen.desktop";
    		"application/x-extension-htm" = "zen.desktop";
    		"application/x-extension-html" = "zen.desktop";
    		"application/x-extension-xhtml" = "zen.desktop";

    		# Text formats -> Kate
    		"text/plain" = "org.kde.kate.desktop";
    		"text/markdown" = "org.kde.kate.desktop";
    		"text/x-markdown" = "org.kde.kate.desktop";
    		"text/x-readme" = "org.kde.kate.desktop";
    		"text/x-log" = "org.kde.kate.desktop";
    		"text/x-patch" = "org.kde.kate.desktop";
    		"text/x-diff" = "org.kde.kate.desktop";

    		# Config formats -> Kate
    		"text/x-config" = "org.kde.kate.desktop";
    		"application/x-config" = "org.kde.kate.desktop";
    		"text/x-ini" = "org.kde.kate.desktop";
    		"application/x-ini" = "org.kde.kate.desktop";
    		"text/x-toml" = "org.kde.kate.desktop";
    		"application/toml" = "org.kde.kate.desktop";
    		"text/x-yaml" = "org.kde.kate.desktop";
    		"application/x-yaml" = "org.kde.kate.desktop";
    		"application/json" = "org.kde.kate.desktop";
    		"text/x-json" = "org.kde.kate.desktop";
    		"application/xml" = "org.kde.kate.desktop";
        	"text/xml" = "org.kde.kate.desktop";

        	# Code formats -> Kate
        	"text/x-python" = "org.kde.kate.desktop";
        	"text/x-python3" = "org.kde.kate.desktop";
        	"text/x-lua" = "org.kde.kate.desktop";
        	"text/x-csrc" = "org.kde.kate.desktop";
        	"text/x-chdr" = "org.kde.kate.desktop";
        	"text/x-c++src" = "org.kde.kate.desktop";
        	"text/x-c++hdr" = "org.kde.kate.desktop";
        	"text/x-java" = "org.kde.kate.desktop";
        	"text/javascript" = "org.kde.kate.desktop";
        	"text/x-nix" = "org.kde.kate.desktop";
        	"text/x-rust" = "org.kde.kate.desktop";
        	"text/css" = "org.kde.kate.desktop";
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
