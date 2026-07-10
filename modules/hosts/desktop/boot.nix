{ config, pkgs, ... }:

{
	# Bootloader.
	boot.loader.limine = {
		secureBoot.enable = true;
		resolution = "1920x1080";
	};
}
