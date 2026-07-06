{ config, pkgs, ... }:

{
	fileSystems."/mnt/ext" =
	{ device = "/dev/disk/by-uuid/5EEFD218069F2932";
		fsType = "ntfs-3g";
		options = [ 
			  "rw" 
			  "dmask=022" 
			  "fmask=133" 
			  "nofail"
			  "windows_names"
		];
	};

	fileSystems."/mnt/hihi" =
	{ device = "/dev/disk/by-uuid/4A1C39811C396959";
		fsType = "ntfs3";
		options = [ 
			  "rw" 
			  "dmask=022" 
			  "fmask=133" 
			  "nofail"
			  "exec"
		];
	};

	fileSystems."/mnt/adu" =
	{ device = "/dev/disk/by-uuid/40a40c3d-72e7-4ad2-a2fa-6e93ff0cf9fb";
		fsType = "ext4";
	};

}
