{ config, pkgs, ... }:

{
	fileSystems."/mnt/ext" =
	{ device = "/dev/disk/by-uuid/5EEFD218069F2932";
		fsType = "ntfs-3g";
		options = [ 
			  "rw" 
			  "uid=1000" 
			  "gid=100" 
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
    "user_id=1000"
    "group_id=100"
    "dmask=022"
    "fmask=133"
    "nofail"
    "exec"
		];
	};

	fileSystems."/mnt/adu" =
	{ device = "/dev/disk/by-uuid/3AD8F535D8F4EFCD";
		fsType = "ntfs3";
		options = [ 
    "rw"
    "user_id=1000"
    "group_id=100"
    "dmask=022"
    "fmask=133"
    "nofail"
    "exec"
		];
	};

}
