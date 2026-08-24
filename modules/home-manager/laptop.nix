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
    		};
  		};

  		gtk4 = {
   			extraConfig = {
      			gtk-application-prefer-dark-theme = 1;
    		};
  		};
	};

  	dconf = {
    	settings = {
      		"org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
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
	    configPackages = with pkgs; [ xdg-desktop-portal-gtk ];
	};

	home.sessionVariables = {
		GTK_THEME = "Adwaita";
		GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
	};




	programs.fish.functions = {
		rebuild = ''
			cd /etc/nixos

			echo "🔄 Updating flake inputs..."
			sudo nix flake update

			echo "📦 Staging local changes..."
			sudo git add .

			read -P "Commit message (leave empty for default): " msg
			if test -z "$msg"
				set msg "update: "(date +%Y-%m-%d)
			end

			echo "💾 Committing changes..."
			sudo git commit -m "$msg"; or true

			echo "🔄 Fetching from remote..."
			sudo git fetch origin

			echo "⚡ Rebasing with local changes taking priority..."
			sudo git rebase -X ours origin/(sudo git branch --show-current); or true

			echo "⬆️  Force pushing to remote..."
			sudo git push --force

			echo "🔨 Rebuilding NixOS (with upgrades)..."
			sudo nixos-rebuild switch --upgrade-all --flake .#laptop

			echo "✅ Done!"
		'';
        pull-nix = ''
        	cd /etc/nixos
            echo "📦 Staging local changes..."
            sudo git add .
                  
            echo "💾 Stashing local changes..."
            sudo git stash
                  
            echo "🔄 Fetching from remote..."
            sudo git fetch origin
                  
            set branch (sudo git branch --show-current)
            echo "🌿 Current branch: $branch"
                  
            set local_commit (sudo git rev-parse HEAD)
            set remote_commit (sudo git rev-parse origin/$branch)
                  
            if test "$local_commit" = "$remote_commit"
            	echo "✅ Already up to date, nothing to rebase."
            else
                echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
                set conflicts (sudo git rebase -X ours origin/$branch 2>&1)
                if test $status -eq 0
                	echo "✅ Rebase successful."
                else
                    echo "⚠️  Rebase had conflicts, local changes were preferred:"
                    echo $conflicts
                end
            end
                  
            echo "📂 Restoring stashed changes..."
            sudo git stash pop; or echo "ℹ️  Nothing to restore from stash."
                  
            echo "🔨 Rebuilding NixOS..."
            sudo nixos-rebuild switch --flake /etc/nixos#desktop
                  
            echo "✅ Done!"
        '';
        pull-dot = ''
            cd ~/.config
            echo "📦 Staging local changes..."
            sudo git add .

            echo "💾 Stashing local changes..."
            sudo git stash

            echo "🔄 Fetching from remote..."
            sudo git fetch origin

            set branch (sudo git branch --show-current)
            echo "🌿 Current branch: $branch"

            set local_commit (sudo git rev-parse HEAD)
            set remote_commit (sudo git rev-parse origin/$branch)

            if test "$local_commit" = "$remote_commit"
            	echo "✅ Already up to date, nothing to rebase."
            else
                echo "⚡ Local and remote differ, rebasing with local changes taking priority..."
                set conflicts (sudo git rebase -X ours origin/$branch 2>&1)
                if test $status -eq 0
                	echo "✅ Rebase successful."
                else
                    echo "⚠️  Rebase had conflicts, local changes were preferred:"
                    echo $conflicts
               	end
            end

            echo "📂 Restoring stashed changes..."
            sudo git stash pop; or echo "ℹ️  Nothing to restore from stash."

            echo "✅ Done!"
       	'';
	};
}
