{ config, pkgs, inputs, lib,  ... }:
{
	environment.systemPackages = with pkgs; [
		# for kde stuff
		kdePackages = {
			dolphin
			ark
			kate		
			ktexteditor
			konsole
			gwenview
			qtsvg
			kio
			kio-fuse
			kio-extras
			kio-admin
			kservice
			kcalc
			qtsvg 
			qtwayland
			kcoreaddons
			kiconthemes
			dolphin-plugins
			ffmpegthumbs
			krdp
			kimageformats # provides Qt plugins
			qtimageformats # provides optional image formats such as .webp and .avif
			kfilemetadata
			qt6ct
			plasma-workspace
			kde-cli-tools
			qtstyleplugin-kvantum
		}

		libsForQt5.qt5ct
		libsForQt5.qtstyleplugin-kvantum
		
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

	programs.hyprland.enable = true;

	virtualisation.docker = {
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};
}
