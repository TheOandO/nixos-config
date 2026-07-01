{ config, pkgs, ... }:

{
	# Bootloader.
  	# boot.loader.systemd-boot.enable = true;
  	# boot.loader.efi.canTouchEfiVariables = true;

  	# Use latest kernel.
  	# boot.kernelPackages = pkgs.linuxPackages_latest;
  	#boot.loader.grub.enable = true;
  	#boot.loader.grub.device = "nodev";
  	#boot.loader.grub.useOSProber = true;
}
