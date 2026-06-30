{ config, pkgs, ... }:

{
	fileSystems."/mnt/ext" =
	{ device = "/dev/disk/by-uuid/5EEFD218069F2932";
		fsType = "ntfs3";
	};

	fileSystems."/mnt/hihi" =
	{ device = "/dev/disk/by-uuid/4A1C39811C396959";
	    fsType = "ntfs3";
	};

	fileSystems."/mnt/adu" =
	{ device = "/dev/disk/by-uuid/3AD8F535D8F4EFCD";
	    fsType = "ntfs3";
	};

}
