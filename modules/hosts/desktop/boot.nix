{ config, pkgs, ... }:

{
	# Bootloader.
	boot.loader.limine.secureBoot.enable = true;
}
