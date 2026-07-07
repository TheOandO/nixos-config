{ config, pkgs, lib, ... }:

{
	fileSystems."/mnt/ext" =
	{ device = "/dev/disk/by-uuid/f3d7288c-184d-4195-b001-9f9a9ecb576c";
		fsType = "ext4";
	};

	fileSystems."/mnt/hihi" =
	{ device = "/dev/disk/by-uuid/d65ec31a-067e-4bf1-87d8-5f7c4e5297e3";
		fsType = "ext4";
	};

	fileSystems."/mnt/adu" =
	{ device = "/dev/disk/by-uuid/40a40c3d-72e7-4ad2-a2fa-6e93ff0cf9fb";
		fsType = "ext4";
	};

	fonts = {
		packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
		fontconfig.defaultFonts = {
		    serif = [ "BigBlueTerm Nerd Font" ];
		    sansSerif = [ "0xProto Nerd Font" ];
		    monospace = [ "DejaVuSansM Nerd Font" ];
		  };
	};
}
