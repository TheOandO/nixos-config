{ config, pkgs, ... }:

{
  	boot = {
		loader = {
			systemd-boot.enable = false;
			limine = {
				enable = true;
				efiSupport = true;
				style = {
					wallpapers = [
						../../wallpapers/wallhaven-rq7leq.jpg
					];
					wallpaperStyle = "tiled";
				};
			};
			efi.canTouchEfiVariables = true;
		};

		kernelPackages = pkgs.linuxPackages_latest;
  	};
}
