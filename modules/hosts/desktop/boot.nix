{ config, pkgs, ... }:

{
	# Bootloader.
	boot.loader.limine = {
		secureBoot.enable = true;
		resolution = "1920x1080";
	};

	#Workaround script for disappearing bootloader
	system.activationScripts.limine-sync = ''
		mkdir -p /boot/efi/Boot
		cp -f /boot/efi/limine/BOOTX64.EFI /boot/efi/Boot/
	'';
}
