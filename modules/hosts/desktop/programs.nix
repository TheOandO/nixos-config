{ config, pkgs, inputs, lib,  ... }:
{
	environment.systemPackages = with pkgs; [
		kdePackages.dolphin
		kdePackages.ark
		kdePackages.kate		
		kdePackages.ktexteditor
		kdePackages.gwenview
		kdePackages.qtsvg
		kdePackages.kio
		kdePackages.kio-fuse
		kdePackages.kio-extras
		kdePackages.kio-admin
		kdePackages.kservice
		kdePackages.kcalc
		kdePackages.qtsvg 
		kdePackages.qtwayland
		kdePackages.kcoreaddons
		kdePackages.kiconthemes
		kdePackages.dolphin-plugins
		kdePackages.ffmpegthumbs
		kdePackages.krdp
		kdePackages.kimageformats # provides Qt plugins
		kdePackages.qtimageformats # provides optional image formats such as .webp and .avif
		kdePackages.kfilemetadata
		libsForQt5.qt5ct
		kdePackages.qt6ct
		kdePackages.plasma-workspace
		desktop-file-utils
  		xdg-utils
		kdePackages.kde-cli-tools

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

		nordic
		kdePackages.qtstyleplugin-kvantum
		libsForQt5.qtstyleplugin-kvantum

		inputs.compose2nix.packages.x86_64-linux.default
		
		lsfg-vk
		lsfg-vk-ui
		heroic
		protonplus
		goverlay
		mangohud
	];

	programs.hyprland.enable = true;

	# programs.dconf.profiles.user.databases = [
	# 	{
	#     	settings."org/gnome/desktop/interface" = {
	#     		color-scheme = "prefer-dark";
	#     	};
	#     }
	# ];

	programs.steam = {
	  enable = true; # Master switch, already covered in installation
	  remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
	  dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
	};
	programs.gamemode.enable = true;

	virtualisation.docker = {
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};
}
