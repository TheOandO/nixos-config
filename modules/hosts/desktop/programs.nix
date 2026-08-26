{ config, pkgs, inputs, lib,  ... }:
{
	environment.systemPackages = with pkgs; [
		# for kde stuff
		kdePackages.dolphin
		kdePackages.ark
		kdePackages.kate
		kdePackages.ktexteditor
		kdePackages.konsole
		kdePackages.gwenview
		kdePackages.qtsvg
		kdePackages.kio
		kdePackages.kio-fuse
		kdePackages.kio-extras
		kdePackages.kio-admin
		kdePackages.kservice
		kdePackages.kcalc
		kdePackages.qtwayland
		kdePackages.kcoreaddons
		kdePackages.kiconthemes
		kdePackages.dolphin-plugins
		kdePackages.ffmpegthumbs
		kdePackages.krdp
		kdePackages.kimageformats # provides Qt plugins
		kdePackages.qtimageformats # provides optional image formats such as .webp and .avif
		kdePackages.kfilemetadata
		kdePackages.qt6ct
		kdePackages.plasma-workspace
		kdePackages.plasma-desktop
		kdePackages.kde-cli-tools
		kdePackages.qtstyleplugin-kvantum

		libsForQt5.qt5ct
		libsForQt5.qtstyleplugin-kvantum

		
		kurve
		cava
	  	(python3.withPackages (ps: with ps; [
	    	websockets
	  	]))
		qt6.qtwebsockets
		
		desktop-file-utils
  		xdg-utils

		inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
		inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default

		clinfo
		(fluent-icon-theme.override {
			colorVariants = [ "green" "orange" ];
		})
		(fluent-gtk-theme.overrideAttrs (old: {
		  installPhase = ''
		    bash install.sh \
		      --dest $out/share/themes \
		      --theme green orange \
		      --color dark \
		      --size standard
		  '';
		}))
		inputs.compose2nix.packages.x86_64-linux.default
	];

	programs = {
		hyprland.enable = true;
	};
	virtualisation.docker = {
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};
}
