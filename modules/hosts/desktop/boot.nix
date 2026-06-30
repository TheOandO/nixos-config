{ config, pkgs, ... }:

{
	# Bootloader.
  	# boot.loader.systemd-boot.enable = true;
  	# boot.loader.efi.canTouchEfiVariables = true;

  	# Use latest kernel.
  	# boot.kernelPackages = pkgs.linuxPackages_latest;
  	boot.extraModprobeConfig = ''
  		options snd_hda_intel power_save=0
  		options snd_hda_intel power_save_controller=N
  	'';
}
