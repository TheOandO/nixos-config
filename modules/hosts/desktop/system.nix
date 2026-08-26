{ config, pkgs, lib, ... }:

{
	fileSystems = {
		"/mnt/ext" =
			{ device = "/dev/disk/by-uuid/C6AC6908AC68F479";
				fsType = "ntfs3";
				options = [ "nofail" ];
			};

		"/mnt/hihi" =
			{ device = "/dev/disk/by-uuid/d65ec31a-067e-4bf1-87d8-5f7c4e5297e3";
				fsType = "ext4";
				options = [ "nofail" ];
			};

		"/mnt/adu" =
			{ device = "/dev/disk/by-uuid/40a40c3d-72e7-4ad2-a2fa-6e93ff0cf9fb";
				fsType = "ext4";
				options = [ "nofail" ];
			};

		"/mnt/nas" = {
				  device = "//mattyomv.local/NAS/";
				  fsType = "cifs";
				  options = let
				    	# automount options: only mounts on first access, unmounts after idle
				    	automount_opts = "x-systemd.automount,noauto";
				  in [
				    	"credentials=/etc/nixos/credentials/omv"
				    	"_netdev"
				    	"uid=1000"
				    	"gid=100"
				    	"file_mode=0664"
				    	"dir_mode=0775"
				    automount_opts
				  ];
			};
	};

}
