{ config, pkgs, ... }:
{
	qt = {
		enable = true;
	};
	xdg.configFile."mimeapps.list".force = true'
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
	
# 	programs.fish.functions = {
# 		rebuild = ''
# 			cd /etc/nixos
#
# 			echo "🔄 Updating flake inputs..."
# 			sudo nix flake update
#
# 			echo "📦 Staging local changes..."
# 			sudo git add .
#
# 			read -P "Commit message (leave empty for default): " msg
# 			if test -z "$msg"
# 				set msg "update: "(date +%Y-%m-%d)
# 			end
#
# 			echo "💾 Committing changes..."
# 			sudo git commit -m "$msg"; or true
#
# 			echo "🔄 Fetching from remote..."
# 			sudo git fetch origin
#
# 			echo "⚡ Rebasing with local changes taking priority..."
# 			sudo git rebase -X ours origin/(sudo git branch --show-current); or true
#
# 			echo "⬆️  Force pushing to remote..."
# 			sudo git push --force
#
# 			echo "🔨 Rebuilding NixOS (with upgrades)..."
# 			sudo nixos-rebuild switch --upgrade-all --flake .#desktop
#
# 			echo "✅ Done!"
# 		'';
# 		pull-nix = ''
# 		  	cd /etc/nixos
# 		  	echo "📦 Staging local changes..."
# 		  	sudo git add .
#
# 		  	echo "💾 Stashing local changes..."
# 		  	sudo git stash
#
# 		  	echo "🔄 Fetching from remote..."
# 		  	sudo git fetch origin
#
# 		  	set branch (sudo git branch --show-current)
# 		  	echo "🌿 Current branch: $branch"
#
# 		  	set local_commit (sudo git rev-parse HEAD)
# 		  	set remote_commit (sudo git rev-parse origin/$branch)
#
# 		  	if test "$local_commit" = "$remote_commit"
# 		    	echo "✅ Already up to date, nothing to rebase."
# 		  	else
# 		    	echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
# 		    	set conflicts (sudo git rebase -X ours origin/$branch 2>&1)
# 		    	if test $status -eq 0
# 		      		echo "✅ Rebase successful."
# 		    	else
# 		      		echo "⚠️  Rebase had conflicts, local changes were preferred:"
# 		      		echo $conflicts
# 		    	end
# 		  	end
#
# 		  	echo "📂 Restoring stashed changes..."
# 		  	sudo git stash pop; or echo "ℹ️  Nothing to restore from stash."
#
# 		  	echo "🔨 Rebuilding NixOS..."
# 		  	sudo nixos-rebuild switch --flake /etc/nixos#desktop
#
# 		  	echo "✅ Done!"
# 		'';
# 		pull-dot = ''
# 		  	cd ~/.config
# 		  	echo "📦 Staging local changes..."
# 		  	sudo git add .
#
# 		  	echo "💾 Stashing local changes..."
# 		  	sudo git stash
#
# 		  	echo "🔄 Fetching from remote..."
# 		  	sudo git fetch origin
#
# 		  	set branch (sudo git branch --show-current)
# 		  	echo "🌿 Current branch: $branch"
#
# 		  	set local_commit (sudo git rev-parse HEAD)
# 		  	set remote_commit (sudo git rev-parse origin/$branch)
#
# 		  	if test "$local_commit" = "$remote_commit"
# 		    	echo "✅ Already up to date, nothing to rebase."
# 		  	else
# 		    	echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
# 		    	set conflicts (sudo git rebase -X ours origin/$branch 2>&1)
# 		    	if test $status -eq 0
# 		      		echo "✅ Rebase successful."
# 		    	else
# 		      		echo "⚠️  Rebase had conflicts, local changes were preferred:"
# 		      		echo $conflicts
# 		    	end
# 		  	end
#
# 		  	echo "📂 Restoring stashed changes..."
# 		  	sudo git stash pop; or echo "ℹ️  Nothing to restore from stash."
#
# 		  	echo "✅ Done!"
# 		'';
# 	};

}
