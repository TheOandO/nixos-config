{ config, pkgs, ... }:

{
	# Set your time zone.
  	time.timeZone = "Europe/Stockholm";

  	# Select internationalisation properties.
  	i18n.defaultLocale = "en_US.UTF-8";

  	i18n.extraLocaleSettings = {
    		LC_ADDRESS = "en_US.UTF-8";
    		LC_IDENTIFICATION = "en_US.UTF-8";
    		LC_MEASUREMENT = "en_US.UTF-8";
    		LC_MONETARY = "en_US.UTF-8";
    		LC_NAME = "en_US.UTF-8";
    		LC_NUMERIC = "en_US.UTF-8";
    		LC_PAPER = "en_US.UTF-8";
    		LC_TELEPHONE = "en_US.UTF-8";
    		LC_TIME = "en_US.UTF-8";
  	};

  	# Define a user account. Don't forget to set a password with ‘passwd’.
  	users.users."matty" = {
    		isNormalUser = true;
    		description = "Matty";
    		extraGroups = [ "networkmanager" "wheel" "samba" ];
    		shell = pkgs.fish;
    		packages = with pkgs; [];
  	};

  #	environment.shellAliases = {
  #		rebuild = "cd /etc/nixos && git add . && (git commit -m \"update: $(date +%Y-%m-%d)\" || true) && git push && nix flake update --flake /etc/nixos && nixos-rebuild switch --flake .#matty";
#	};
}
