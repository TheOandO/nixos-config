# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  	imports = [
      		./modules/common/services.nix
			./modules/common/networking.nix
			./modules/common/programs.nix
			./modules/common/boot.nix
			./modules/common/security.nix
			./modules/common/system.nix
    	];

  	# Allow unfree packages
  	nixpkgs.config.allowUnfree = true;
# 
# 	nixpkgs.config.permittedInsecurePackages = [
# 		"pnpm-10.29.2"
# 	];

	nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  	# This value determines the NixOS release from which the default
  	# settings for stateful data, like file locations and database versions
  	# on your system were taken. It‘s perfectly fine and recommended to leave
  	# this value at the release version of the first install of this system.
  	# Before changing this value read the documentation for this option
  	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  	system.stateVersion = "26.05"; # Did you read the comment?
}
