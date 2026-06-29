{ config, pkgs, ... }:
{
	programs.fish.functions.rebuild = ''
	  	cd /etc/nixos
	  	sudo git fetch
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
