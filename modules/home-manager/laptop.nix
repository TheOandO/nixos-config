{ config, pkgs, ... }:
{
	# xdg.configFile."niri/config.kdl".source = ./config.kdl;
	
  	gtk = {
    	enable = true;
    	iconTheme = {
      		name = "Papirus-Dark";
      		package = pkgs.papirus-icon-theme;
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
	  	sudo nixos-rebuild switch --upgrade-all --flake .#laptop
	'';
}
