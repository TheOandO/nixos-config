{ config, pkgs, ... }:

{
	# Bootloader.
	boot.loader.systemd-boot.enable = false;
	boot.loader.limine = {
		enable = true;
		efiSupport = true;
	};
  	boot.loader.efi.canTouchEfiVariables = true;

  	# Use latest kernel.
  	boot.kernelPackages = pkgs.linuxPackages_latest;
}
