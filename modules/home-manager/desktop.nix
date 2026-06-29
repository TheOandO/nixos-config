{ config, pkgs, ... }:
{
	home.pointerCursor = {
	  gtk.enable = true;
	  # x11.enable = true;
	  package = pkgs.bibata-cursors;
	  name = "Bibata-Modern-Classic";
	  size = 16;
	};

	programs.fish.functions.rebuild = ''
	  	cd /etc/nixos
	  	sudo git fetch
	  	sudo git pull
	  	sudo git add .
	  	read -P "Commit message (leave empty for default): " msg
	  	if test -z "$msg"
	    	set msg "update: "(date +%Y-%m-%d)
	  	end
	  	sudo git commit -m "$msg"; or true
	  	sudo git push
	  	sudo nix flake update
	  	sudo nixos-rebuild switch --upgrade-all --flake .#desktop
	'';
}
