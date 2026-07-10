{ config, pkgs, ... }:

{
	# Bootloader.
	boot.loader.systemd-boot.enable = false;
	boot.loader.limine = {
		enable = true;
		efiSupport = true;
		style = {
			wallpapers = [
		    	./wallpapers/wallhaven-rq7leq.jpg
		    ];
		    wallpaperStyle = "tiled";
		};
	};
  	boot.loader.efi.canTouchEfiVariables = true;

  	# Use latest kernel.
  	boot.kernelPackages = pkgs.linuxPackages_latest;
}
